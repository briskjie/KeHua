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
        MIIC6TCCAdGgAwIBAgIJAMfyOEsZi2MoMA0GCSqGSIb3DQEBDAUAMBQxEjAQBgNV
        BAMTCWxvY2FsaG9zdDAeFw0yNTA4MzAwMzU5MDhaFw0zNTA4MjgwMzU5MDhaMBQx
        EjAQBgNVBAMTCWxvY2FsaG9zdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
        ggEBAPA7DWkpz6GxD9UGYUFdaTm3wncrMx6kQOV6BQ7wMdlJ0Afil+2Lf74Kxveh
        PFZcIoXRJcj9deuDi03hyD9VFnSZlHhLkWqg+UKqB09rw9LdxBhEwCUOjMsmWlx6
        LdVbd9ttsZ6XXyAAPyQOS8+0vQqpCZFt9HYUZHv6uC/7GSKEX6ig2leIMKUdnnKX
        BAtWSTF+6kgoSrStm6H4K6aNKEJbgNSCEo84cSCoERI2jL8opmqY8/Z/Mfdl7s9q
        AWwiKL1Q7z5TMdXuXkJSBwZ3Hqdiqz7HhKUUqC8VnRT8/JuD43GSM/0BVUJG18Kx
        h0v6DznkqZ9hj7kkHJZCUdKUSlUCAwEAAaM+MDwwHQYDVR0OBBYEFMfOx1uS1Oxs
        g0psv5iIEfAcfNFiMBsGA1UdEQQUMBKHBMCoAr+HBKwa4WSHBHgwGT4wDQYJKoZI
        hvcNAQEMBQADggEBAOdg1vVuNaBqv+5GNcQ9BLPpqPfWQ3XM39e3E1nrK/3gApb/
        jx1kw6oQQ77oi00zl4cKQwGYIhFr8ELG75jbFlgkIYuIqy4hGHhRjmjyhswGGnRt
        WKszVAv7eD6GCyDw15cGhhmCHcsxBgvByJT5VRyYP7jio9rW5QPvQcKkNCLZF9Lx
        MGHryudW3c0tETXUvtsHOhmkJnw4nDEM2Xjnlh66WL3j6SgnDBZWtoTDW6BtkpPz
        Nt2HmONSVvF/wYuFd52Swt8Zpnl6GuwqOPt45KmNMTmzJe+Cnbt+ckOLjRJmnSSX
        /VWTVGTbuafuvSaFrXzTdzuTRtGgYGTa2QJSS5o=
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
    let certificateData: Data
    
    init(certificate: String) {
        self.certificateData = Data(certificate.utf8)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // 1. 创建证书对象
        guard let cert = SecCertificateCreateWithData(nil, certificateData as CFData) else {
            print("⚠️ 无法创建证书对象")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        // 2. 设置信任策略
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust, policies)
        
        // 3. 设置锚点证书
        SecTrustSetAnchorCertificates(serverTrust, [cert] as CFArray)
        SecTrustSetAnchorCertificatesOnly(serverTrust, true)
        
        // 4. 评估信任
        var error: CFError?
        if SecTrustEvaluateWithError(serverTrust, &error) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("⚠️ 证书验证失败: \(error?.localizedDescription ?? "未知错误")")
            // 生产环境中应使用.cancelAuthenticationChallenge
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
}