Pod::Spec.new do |s|
  s.name = 'OpenSSL'
  s.version = '1.0.210'

  s.license = 'BSD-style Open Source'
  s.summary = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in Mac OS and gone in iOS, this spec gives your project non-deprecated OpenSSL support."
  s.author          = "OpenSSL Project <openssl-dev@openssl.org>"

  s.homepage        = "https://github.com/FredericJacobs/OpenSSL-Pod"
  s.source          = { :git => '', :tag => s.version.to_s}
  s.source_files    = "openssl/*.h"
  s.header_dir      = "openssl"
 

  s.ios.deployment_target   = "8.0"
  s.ios.public_header_files = "openssl/*.h"
  s.ios.vendored_libraries  = "lib/libcrypto.a", "lib/libssl.a"

  s.libraries             = 'crypto', 'ssl'
  s.requires_arc          = false
end