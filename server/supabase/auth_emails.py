import json

LOGO = "https://raw.githubusercontent.com/techmefr/amiludo/main/design/logo/amiludo-mark.png"
APP = "https://techmefr.github.io/amiludo/app/"


def page(title, intro, button=None, after="", code=False):
    action = ""
    if button:
        action = f"""
      <tr><td align="center" style="padding:8px 0 24px">
        <a href="{{{{ .ConfirmationURL }}}}" style="display:inline-block;background:#6f4fd0;color:#ffffff;text-decoration:none;font-weight:700;font-size:16px;padding:14px 28px;border-radius:999px">{button}</a>
      </td></tr>"""
    token = ""
    if code:
        token = """
      <tr><td align="center" style="padding:0 0 24px">
        <div style="display:inline-block;background:#efe9fb;color:#2b2541;font-size:28px;letter-spacing:6px;font-weight:700;padding:12px 24px;border-radius:16px">{{ .Token }}</div>
      </td></tr>"""
    return f"""<!doctype html>
<html lang="fr">
<body style="margin:0;background:#fff8ef;font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;color:#2b2541">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#fff8ef;padding:32px 16px">
    <tr><td align="center">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;background:#ffffff;border-radius:24px;padding:32px;border:1px solid #ece4d8">
        <tr><td align="center" style="padding-bottom:16px">
          <img src="{LOGO}" width="64" height="64" alt="amiLudo" style="display:block">
        </td></tr>
        <tr><td align="center" style="font-size:24px;font-weight:800;padding-bottom:8px">{title}</td></tr>
        <tr><td align="center" style="font-size:16px;line-height:1.5;color:#4a4560;padding-bottom:24px">{intro}</td></tr>{token}{action}
        <tr><td align="center" style="font-size:13px;line-height:1.5;color:#7a7590">{after}</td></tr>
      </table>
      <p style="font-size:12px;color:#9a94ad;margin:16px 0 0">amiLudo · Tous les outils, autour de la table · <a href="{APP}" style="color:#6f4fd0">ouvrir l’app</a></p>
    </td></tr>
  </table>
</body>
</html>"""


IGNORE = "Si vous n’êtes pas à l’origine de cette demande, ignorez simplement ce message."
SECURITY = "Si ce n’est pas vous, réinitialisez votre mot de passe sans attendre."

templates = {
    "confirmation": (
        "Bienvenue dans amiLudo 🎲",
        page("Bienvenue autour de la table !",
             "Confirmez votre adresse e-mail pour activer votre compte et rejoindre les soirées de vos amis.",
             "Confirmer mon adresse", IGNORE + " Ce lien expire dans 1 heure."),
    ),
    "magic_link": (
        "Votre lien de connexion amiLudo",
        page("Votre lien de connexion",
             "Touchez le bouton pour vous connecter à amiLudo, sans mot de passe. Vous pouvez aussi saisir ce code dans l’app :",
             "Me connecter", IGNORE + " Ce lien et ce code expirent dans 1 heure.", code=True),
    ),
    "recovery": (
        "Réinitialiser votre mot de passe amiLudo",
        page("Mot de passe oublié ?",
             "Pas de panique. Touchez le bouton pour choisir un nouveau mot de passe.",
             "Choisir un nouveau mot de passe", IGNORE + " Ce lien expire dans 1 heure."),
    ),
    "invite": (
        "Vous êtes invité sur amiLudo 🎲",
        page("Vous êtes invité !",
             "Un compte amiLudo vous attend. Acceptez l’invitation pour choisir votre mot de passe.",
             "Accepter l’invitation", IGNORE),
    ),
    "email_change": (
        "Confirmez votre nouvelle adresse amiLudo",
        page("Nouvelle adresse e-mail",
             "Confirmez que {{ .NewEmail }} sera désormais l’adresse de votre compte amiLudo.",
             "Confirmer la nouvelle adresse", IGNORE),
    ),
    "reauthentication": (
        "{{ .Token }} est votre code amiLudo",
        page("Votre code de vérification",
             "Saisissez ce code dans amiLudo pour confirmer l’opération :",
             None, IGNORE, code=True),
    ),
    "password_changed_notification": (
        "Votre mot de passe amiLudo a changé",
        page("Mot de passe modifié",
             "Le mot de passe du compte {{ .Email }} vient d’être modifié.", None, SECURITY),
    ),
    "email_changed_notification": (
        "Votre adresse amiLudo a changé",
        page("Adresse e-mail modifiée",
             "L’adresse de votre compte est passée de {{ .OldEmail }} à {{ .Email }}.", None, SECURITY),
    ),
}

payload = {}
for name, (subject, html) in templates.items():
    payload[f"mailer_subjects_{name}"] = subject
    payload[f"mailer_templates_{name}_content"] = html
print(json.dumps(payload))
