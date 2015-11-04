CA_CONF=ca.cnf
CRT_CONF=crt.cnf
SAN_PROMPT=Enter alternative names (eg. DNS.1:example.com, DNS.2:www.example.com):
OPENSSL=QUICKSTART_SAN=${SAN} openssl

.PHONY: init ca ca_key_exists clean
.PRECIOUS: %.key

# OpenSSL requires database files to be initialized before it can process
# signing requests with a CA.
init:
	[ -d newcerts ] || mkdir newcerts
	[ -f serial ] || echo 01 > serial
	touch index.txt

# Generate a key pair and a self-signed certificate to be used as a CA.
# The `-days` option specifies for how long it remains valid.
ca:
	@[ -d ca ] || mkdir ca
	${OPENSSL} req -new -nodes -x509 -days 3650 -out ca/ca.crt -keyout ca/ca.key \
		-config "${CA_CONF}" -extensions v3_ca
	chmod go-rw ca/ca.key

# Output a friendly error message if the CA key pair cannot be found.
ca_key_exists:
	@[ -f ca/ca.key ] \
		|| (echo 'Missing CA key: ca/ca.key.  You can create it with `make ca`'; exit 1)

# Generate an RSA key pair with a key size of 4096 bits.
%.key:
	${OPENSSL} genrsa -out "$@" 4096
	chmod go-rw "$@"

# Generate a signing request.  Generate the key if it is not present.
%.csr: %.key
	$(eval SAN = $(shell bash -c 'read -p "${SAN_PROMPT} " san; echo $$san'))
	${OPENSSL} req -new -key "$<" -out "$@" -config "${CRT_CONF}" -extensions v3_req

# Make sure `ca/ca.key` is present and process a signing request.
%.crt: ca_key_exists init %.csr
	${OPENSSL} ca -in "$*.csr" -out "$@" -config "${CRT_CONF}" \
		-extensions v3_req -extfile "${CRT_CONF}"
# Clean working directory.  Be careful as this task removes all certificates,
# keys and the database!
clean:
	rm -f ca/ca.{crt,key} *.{crt,csr,key} serial{,.old} index.txt{,.attr,.old,.attr.old}
	[ ! -d ca ] || rmdir ca
	rm -rf newcerts
