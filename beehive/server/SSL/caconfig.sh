#!/bin/bash
oldDir=.

cd DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) # Now in /SSL/

# Begin constructing the Certificate Authority
cd waggleca

# Make appropriate folders
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt

# Generate the root certificate

openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 \
	-out cacert.pem -outform PEM -subj /CN=waggleca/ -nodes

openssl x509 -in cacert.pem -out cacert.cer -outform DER

# Make the server certificate

cd .. # in SSL/

mkdir server
chmod 744 server
cd server

openssl genrsa -out key.pem 2048

openssl req -new -key key.pem -out req.pem -outform PEM \
	-subj /CN=$(hostname)/O=server/ -nodes

cd ../waggleca

openssl ca -config openssl.cnf -in ../server/req.pem -out \
	../server/cert.pem -notext -batch -extensions server_ca_extensions

cd ../server
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:waggle

cd ..
# Move files to correct places
mv rabbit.config /etc/rabbitmq/

mkdir /usr/lib/waggle/

# in SSL/
cd ..
mv SSL /usr/lib/waggle/

cd $oldDir