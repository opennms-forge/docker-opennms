################################################################################
# This file is the configuration for the the JavaMailer class.  It is used to
# specify the details of the JavaMailer system properties
################################################################################
#
# Properties are defined but commented out indicating the default values.
#

#
# This property defines system sender account.
#
# The default setting is root@[127.0.0.1]
org.opennms.core.utils.fromAddress=${OPENNMS_MAIL_FROM}

#
# These properties define the SMTP Host.
#
org.opennms.core.utils.mailHost=${OPENNMS_MAIL_SMTPHOST}
#org.opennms.core.utils.mailer=smtpsend
#org.opennms.core.utils.transport=smtp
#org.opennms.core.utils.debug=true
#org.opennms.core.utils.smtpport=25
#org.opennms.core.utils.smtpssl.enable=false
#org.opennms.core.utils.quitwait=true
#
# This property controls the use of the JMTA
# if it is true, mailHost will be ignored
org.opennms.core.utils.useJMTA=false
#
# These properties define the Mail authentication.
#
#org.opennms.core.utils.authenticate=false
#org.opennms.core.utils.authenticateUser=opennms
#org.opennms.core.utils.authenticatePassword=opennms
#org.opennms.core.utils.starttls.enable=false

#
# These properties configure message content
#
#org.opennms.core.utils.messageContentType=text/plain
#org.opennms.core.utils.charset=us-ascii
