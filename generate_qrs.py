import qrcode

def generate_qr(data, filename):
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    img.save(filename)
    print(f"Generated {filename} for {data}")

# Suspicious: HTTP, keywords, free hosting
generate_qr("http://secure-login.paypal-verify.000webhost.com", "suspicious_qr.png")

# Dangerous: Typosquatting, suspicious TLD
generate_qr("https://faceb00k-login-secure.xyz", "dangerous_qr.png")

# Safe
generate_qr("https://google.com", "safe_qr.png")
