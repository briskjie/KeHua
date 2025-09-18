import SwiftUI
import Security
import Foundation

struct LoginView: View {
    @State private var phone = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("登录")
                .font(.largeTitle)
                .padding()
            
            TextField("手机号", text: $phone)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)
                .padding()
            
            SecureField("密码", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("登录")
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)
            .padding()
        }
        .padding()
    }
    
    private func login() {
        guard !phone.isEmpty, !password.isEmpty else {
            errorMessage = "手机号和密码不能为空"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        let url = URL(string: "https://120.48.25.62/api/users/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "phone": phone,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            errorMessage = "创建请求数据失败"
            isLoading = false
            return
        }
        
        // 配置自定义证书
        let certificate = """
        -----BEGIN CERTIFICATE-----
        MIIDITCCAgmgAwIBAgIUHaRxTQ7qzOErmAE8egBEkOcFxOkwDQYJKoZIhvcNAQEL
        BQAwGDEWMBQGA1UEAwwNS2VIdWEgUm9vdCBDQTAeFw0yNTA5MTgwODI4MjZaFw00
        NTA5MTMwODI4MjZaMBgxFjAUBgNVBAMMDUtlSHVhIFJvb3QgQ0EwggEiMA0GCSqG
        SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCFAl0W8EL6eV1P3alxw8FG2hI6RhkGPBUk
        WvFwZK4eT1iihvwqHWeTFoPoNeElQj7cE4aeWGSCMOoNTcJlBuCbSLbX2C99CJ50
        cpbziHmMgokr9JO2+4EtyaZKzgXEUhNNxSac4gLtaaq+g5XiffVH8WAcyDxrJ/W2
        QemyoLm0Te7vCfgeS/KeMGRFIAht1pnoqPhKlvSMTWEyGgNBLJz3vul+PA2y7cwY
        RbtXdA2NSpNjFCDfmlc/Unq0J7ot5/JuN3t31J6VCjnoX5HdpdmtXrPUvSJ7HSjt
        RYzyGIjcn/zWMaERSDZQU2XKGcPH+j7dRgVCN5bjIXMvcWTQmQrvAgMBAAGjYzBh
        MB0GA1UdDgQWBBTuudHXlKM4CPRQ2Gc32zXHhPeyZjAfBgNVHSMEGDAWgBTuudHX
        lKM4CPRQ2Gc32zXHhPeyZjAPBgNVHRMBAf8EBTADAQH/MA4GA1UdDwEB/wQEAwIB
        BjANBgkqhkiG9w0BAQsFAAOCAQEAD0lIORSn2nNluGcRpMzbJtCcgBiiI/UuOmSe
        PV5RbKloah/YZdjChKRyi1szKTUnpp6SfJS3eJSLRozzJI3POpqUYnmba+xB9EBP
        D0mLtUoNX5JBJFAfEtHo+2lKepZxkq8044x8VTOprACG7NXJJPkeDR0oceK/h6dP
        RwEDav+uYB8Pd2KvI5plXYhFTkTXfYv5FEdc/5gYCbzCYGT2FWWImHNMlzsI9xC8
        9QuX6D82/t1JaSrvLpSw2Kht2sa7tWKmtrL+xqF1EotMWwPhi++zVodwAwyiYVbc
        EqsfW7Chzt56zbsyMaMNfVveUFqHEtkzdq9aUtD0t1bUPCt5/A==
        -----END CERTIFICATE-----
        """
        
        let session = URLSession(configuration: .default, delegate: CertificateDelegate(certificate: certificate), delegateQueue: nil)
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "请求失败: \(error.localizedDescription)"
                    print("登录请求失败: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "无效的服务器响应"
                    print("无效的服务器响应")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    isLoggedIn = true
                    print("登录成功")
                } else {
                    errorMessage = "登录失败: 状态码 \(httpResponse.statusCode)"
                    print("登录失败 - 状态码: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("服务器响应: \(responseString)")
                    }
                }
            }
        }
        
        task.resume()
    }
}

class CertificateDelegate: NSObject, URLSessionDelegate {
    let certificateString: String
    
    init(certificate: String) {
        self.certificateString = certificate
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("🔍 收到认证挑战: \(challenge.protectionSpace.host)")
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            print("⚠️ 非服务器信任挑战或无效的serverTrust")
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // 1. 打印服务器证书信息
        printServerCertificateInfo(serverTrust)
        
        // 2. 从PEM格式字符串创建证书
        let pemString = certificateString
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let pemData = Data(base64Encoded: pemString) else {
            print("❌ 无法将PEM字符串转换为Data - 请检查Base64编码")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        guard let cert = SecCertificateCreateWithData(nil, pemData as CFData) else {
            print("❌ 无法从PEM数据创建证书对象")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // 3. 设置信任策略
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust, policies)
        
        // 4. 设置锚点证书
        SecTrustSetAnchorCertificates(serverTrust, [cert] as CFArray)
        SecTrustSetAnchorCertificatesOnly(serverTrust, true)
        
        // 5. 评估信任
        var error: CFError?
        if SecTrustEvaluateWithError(serverTrust, &error) {
            print("✅ 证书验证成功 - 允许连接")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("⚠️ 证书验证失败: \(error?.localizedDescription ?? "未知错误")")
            print("⚠️ 开发环境中允许继续连接")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
    private func printServerCertificateInfo(_ trust: SecTrust) {
        let count = SecTrustGetCertificateCount(trust)
        print("🔐 服务器提供了 \(count) 个证书")
        
        for i in 0..<count {
            if let cert = SecTrustGetCertificateAtIndex(trust, i) {
                var commonName: CFString?
                SecCertificateCopyCommonName(cert, &commonName)
                print("  证书 #\(i+1): \(commonName as String? ?? "无CN")")
            }
        }
    }
}
