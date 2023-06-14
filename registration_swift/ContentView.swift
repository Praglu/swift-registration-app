import SwiftUI

func isValidEmail(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailPredicte = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicte.evaluate(with: email)
}


struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isEmailValid: Bool = true
    @State private var isShowingRegistrationView = false
    @State private var loggingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    let databaseManager = DatabaseManager.shared
    
    func goToRegistration() {
        isShowingRegistrationView = true
        let registrationView = RegistraionView(isPresented: self.$isShowingRegistrationView)
        let registrationViewHostinController = UIHostingController(rootView: registrationView)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first {
            window.rootViewController?.present(registrationViewHostinController, animated: true, completion: nil)
        }
    }
    
    var body: some View {
        VStack {
            Text("LOGOWANIE")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()

            TextField("Adres email", text: $email)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            
            SecureField("Hasło", text: $password)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
            
            Button(action: {
                if let result = databaseManager.executeQuery(query: "SELECT * FROM users WHERE email='\(email.lowercased())' AND password='\(password)'") {
                    if result.count > 0 {
                        print("ContentView | Zalogowano poprawnie")
                        loggingAlert = true
                        alertTitle = "Zalogowano pomyślnie!"
                        alertMessage = ""
                    } else {
                        print("ContentView | Wprowadzono błędne dane")
                        loggingAlert = true
                        alertTitle = "Błąd logowania"
                        alertMessage = "Wprowadzono nieprawidłowy e-mail lub hasło"
                    }
                } else {
                    print("ContentView | ERROR - Error while logging in!")
                    loggingAlert = true
                    alertTitle = "Błąd bazy danych"
                    alertMessage = "Spróbuj włączyć i wyłączyć aplikację"
                }
            }) {
                Text("Zaloguj się")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width)
            
            Button(action: {
                goToRegistration()
            }) {
                Text("Przejdź do rejestracji")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width)
            
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width)
        .alert(isPresented: $loggingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                loggingAlert = false
                alertTitle = ""
                alertMessage = ""
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct RegistraionView: View {
    @State private var registerEmail: String = ""
    @State private var registerPassword1: String = ""
    @State private var registerPassword2: String = ""
    @State private var isEmailValid: Bool = true
    @State private var registratingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    
    let databaseManager = DatabaseManager.shared
    
    func goToLogin() {
        self.isPresented = false
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        VStack {
            Text("REJESTRACJA")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                
            TextField("Adres email", text: $registerEmail)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                
            SecureField("Hasło", text: $registerPassword1)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                
            SecureField("Powtórz hasło", text: $registerPassword2)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
        
            Button(action: {
                isEmailValid = isValidEmail(email: registerEmail)
                if isEmailValid {
                    if !self.registerPassword1.isEmpty {
                        if self.registerPassword1 == self.registerPassword2 {
                            if let result = databaseManager.executeQuery(query: "SELECT * FROM users WHERE email='\(registerEmail.lowercased())'") {
                                if result.count > 0 {
                                    registratingAlert = true
                                    alertTitle = "Błąd rejestracji"
                                    alertMessage = "Wprowadzony adres e-mail już istnieje w bazie!"
                                    print("RegistrationView | Error - Provided email already exists")
                                } else {
                                    if databaseManager.insertUserIntoUsers(email: registerEmail, password: registerPassword1) {
                                        registratingAlert = true
                                        alertTitle = "Rejestracja pomyślna"
                                        alertMessage = "Udało Ci się zarejestrować konto!"
                                        print("RegistrationView | User registered correctly")
                                    } else {
                                        registratingAlert = true
                                        alertTitle = "Ups! Coś poszło nie tak!"
                                        alertMessage = "Wystąpił nieoczekiwany błąd bazy danych"
                                        print("RegistrationView | Error - Error while inserting new user")
                                    }

                                }
                            } else {
                                registratingAlert = true
                                alertTitle = "Błąd bazy danych"
                                alertMessage = "Nieoczekiwany błąd podczas procesu rejestracji!"
                                print("RegistrationView | Error - Error while registrating new user")
                            }
                        } else {
                            registratingAlert = true
                            alertTitle = "Błąd rejestracji"
                            alertMessage = "Wprowadzone hasła różnią się"
                            print("RegistrationView | Error - Provided passwords are not equal")
                        }
                    } else {
                        registratingAlert = true
                        alertTitle = "Błąd rejestracji"
                        alertMessage = "Hasło nie może być puste"
                        print("RegistrationView | Error - Password cannot be empty")
                    }
                } else {
                    registratingAlert = true
                    alertTitle = "Błąd rejestracji"
                    alertMessage = "E-mail nie spełnia wymagań formatu"
                    print("RegistrationView | Error - Email has bad format")
                }
            }) {
                Text("Zarejestruj się")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width)
            
            Button(action: {
                goToLogin()
            }) {
                Text("Przejdź do logowania")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width)
            
            Button(action: {
                if databaseManager.deleteUsersData() {
                    registratingAlert = true
                    alertTitle = "Usuwanie użytkowników"
                    alertMessage = "Dane użytkowników zostały usunięte"
                } else {
                    registratingAlert = true
                    alertTitle = "Błąd usuwania użytkowników"
                    alertMessage = "Dane użytkowników NIE zostały usunięte"
                }
            }) {
                Text("Usuń dane użytkowników")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width)
        }
        .padding()
        .alert(isPresented: $registratingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                registratingAlert = false
                alertTitle = ""
                alertMessage = ""
            })
        }
    }
}
