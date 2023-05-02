import smtplib

smtp_host = '<smtp_host>'
smtp_port = 465

mail_user = '<user>'
mail_password = '<password>'

sent_from = "from@some.com"
to = ['to@some.com']

subject = 'Smtp Test email'
body = 'Smtp Test email'

email_text = """\
From: %s
To: %s
Subject: %s

%s
""" % (sent_from, ", ".join(to), subject, body)

try:
    smtp_server = smtplib.SMTP_SSL(smtp_host, smtp_port)
    smtp_server.ehlo()
    smtp_server.login(mail_user, mail_password)
    smtp_server.sendmail(sent_from, to, email_text)
    smtp_server.close()
    print("Email sent successfully!")
except Exception as ex:
    print("Something went wrong….", ex)
