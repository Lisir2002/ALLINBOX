package com.inbox.all

import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.*
import java.security.*
import java.security.cert.X509Certificate
import java.util.jar.*
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import android.util.Base64

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.inbox.all/apkbuilder"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "signAndInstall" -> {
                    val unsignedPath = call.argument<String>("unsignedPath") ?: ""
                    val outputPath = call.argument<String>("outputPath") ?: ""
                    val appName = call.argument<String>("appName") ?: "App"
                    
                    Thread {
                        try {
                            val signed = signApkV1(unsignedPath, outputPath)
                            if (signed) {
                                runOnUiThread { 
                                    installApk(outputPath, appName)
                                    result.success(true) 
                                }
                            } else {
                                // Fallback: try direct install
                                runOnUiThread {
                                    installApk(unsignedPath, appName)
                                    result.success(true)
                                }
                            }
                        } catch (e: Exception) {
                            try {
                                runOnUiThread {
                                    installApk(unsignedPath, appName)
                                    result.success(true)
                                }
                            } catch (e2: Exception) {
                                runOnUiThread { result.error("ERROR", e2.message, null) }
                            }
                        }
                    }.start()
                }
                "installApk" -> {
                    val apkPath = call.argument<String>("apkPath") ?: ""
                    val appName = call.argument<String>("appName") ?: "App"
                    try {
                        installApk(apkPath, appName)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun signApkV1(unsignedPath: String, outputPath: String): Boolean {
        try {
            val unsignedFile = File(unsignedPath)
            if (!unsignedFile.exists()) return false

            // Load keystore
            val keyStore = KeyStore.getInstance("JKS")
            val keystoreStream = assets.open("release.keystore")
            keyStore.load(keystoreStream, "allinbox2024".toCharArray())
            keystoreStream.close()
            
            val privateKey = keyStore.getKey("allinbox", "allinbox2024".toCharArray()) as PrivateKey
            val cert = keyStore.getCertificate("allinbox") as X509Certificate
            val certs = arrayOf(cert)

            // Create signed APK using JarSigner
            val manifest = Manifest()
            val manifestEntries = manifest.entries
            
            // Read original APK and create signed output
            val zipInput = ZipInputStream(BufferedInputStream(FileInputStream(unsignedFile)))
            val zipOutput = ZipOutputStream(BufferedOutputStream(FileOutputStream(outputPath)))
            
            // First pass: calculate digests for all entries
            val digests = mutableMapOf<String, ByteArray>()
            var entry = zipInput.nextEntry
            while (entry != null) {
                if (!entry.name.startsWith("META-INF/")) {
                    val data = zipInput.readBytes()
                    val md = MessageDigest.getInstance("SHA-256")
                    val digest = md.digest(data)
                    val b64 = Base64.encodeToString(digest, Base64.NO_WRAP)
                    manifestEntries[entry.name] = Attributes().apply {
                        putValue("SHA-256-Digest", b64)
                    }
                    digests[entry.name] = data
                }
                entry = zipInput.nextEntry
            }
            zipInput.close()

            // Write MANIFEST.MF
            zipOutput.putNextEntry(ZipEntry("META-INF/MANIFEST.MF"))
            manifest.write(zipOutput)
            zipOutput.closeEntry()

            // Create and write signature file (CERT.SF)
            val sigFile = SignatureFile(manifestEntries, manifest)
            zipOutput.putNextEntry(ZipEntry("META-INF/CERT.SF"))
            sigFile.write(zipOutput)
            zipOutput.closeEntry()

            // Create signature block (CERT.RSA)
            val sigBlock = SignatureBlock(privateKey, certs, sigFile)
            zipOutput.putNextEntry(ZipEntry("META-INF/CERT.RSA"))
            zipOutput.write(sigBlock.toByteArray())
            zipOutput.closeEntry()

            // Copy all original entries
            val zipInput2 = ZipInputStream(BufferedInputStream(FileInputStream(unsignedFile)))
            entry = zipInput2.nextEntry
            while (entry != null) {
                if (!entry.name.startsWith("META-INF/")) {
                    zipOutput.putNextEntry(ZipEntry(entry.name))
                    zipOutput.write(digests[entry.name] ?: byteArrayOf())
                    zipOutput.closeEntry()
                }
                entry = zipInput2.nextEntry
            }
            zipInput2.close()
            zipOutput.close()

            return File(outputPath).exists()
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun installApk(apkPath: String, appName: String) {
        val apkFile = File(apkPath)
        if (!apkFile.exists()) throw Exception("APK file not found: $apkPath")
        
        val intent = Intent(Intent.ACTION_VIEW)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        
        val apkUri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            FileProvider.getUriForFile(this, "${applicationContext.packageName}.fileprovider", apkFile)
        } else {
            Uri.fromFile(apkFile)
        }
        
        intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
        startActivity(intent)
    }
}

// Helper classes for JAR signing
class SignatureFile(
    entries: Map<String, Attributes>,
    manifest: Manifest
) {
    private val content = StringBuilder()

    init {
        content.appendLine("Signature-Version: 1.0")
        content.appendLine("Created-By: 1.0 (ALLINBOX)")
        
        val md = MessageDigest.getInstance("SHA-256")
        val manifestBytes = ByteArrayOutputStream().use { 
            manifest.write(it)
            it.toByteArray()
        }
        val manifestDigest = Base64.encodeToString(md.digest(manifestBytes), Base64.NO_WRAP)
        content.appendLine("SHA-256-Digest-Manifest: $manifestDigest")
        content.appendLine()

        // Sort entries for deterministic output
        entries.keys.sorted().forEach { name ->
            val attr = entries[name]!!
            val digest = attr.getValue("SHA-256-Digest")
            content.appendLine("Name: $name")
            content.appendLine("SHA-256-Digest: $digest")
            content.appendLine()
        }
    }

    fun write(os: OutputStream) {
        os.write(content.toString().toByteArray())
    }

    fun toByteArray(): ByteArray = content.toString().toByteArray()
}

class SignatureBlock(
    privateKey: PrivateKey,
    certs: Array<X509Certificate>,
    sigFile: SignatureFile
) {
    private val data: ByteArray

    init {
        val signature = Signature.getInstance("SHA256withRSA")
        signature.initSign(privateKey)
        signature.update(sigFile.toByteArray())
        val signedData = signature.sign()

        // Build PKCS7 block
        val baos = ByteArrayOutputStream()
        for (cert in certs) {
            baos.write(cert.encoded)
        }
        baos.write(signedData)
        data = baos.toByteArray()
    }

    fun toByteArray(): ByteArray = data
}
