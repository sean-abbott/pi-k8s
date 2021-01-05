[day 11](day_11.md)
Ok, I fell off this for awhile, and besides not having added anything, another consequence is that I also for got to journal. But now I'm back. For a couple of days at least.

Ok. So. The etcd cluster that I worked so hard to make happen just keeps falling over, so I'm gonna ditch it. Instead, for now, to get back to working DNS (right before testing HA clusters which don't use it :face_with_rolling_eyes:), I'm working on just using the cluster etcd for the coredns/external dns instance.

I've already ripped out the the etcd operator. I've figured how to connect to the (secured) cluster etcd, and I've figured out how to generate client certificates so that I'm not using the server key to connec to etcd. I've verified I can use etcd from a different node, and I've verified I can see the server's etcd cluster from inside the cluster.

This is all probably gonna be OBE as soon as I switch to using HA, which uses DQLite, so then I'll have to figure out how to run etcd. Again. Whatever.

Ok, so connecting to etcd:
```
export ETCDCTL_API=3
export ETCDCTL_CACERT=/var/snap/microk8s/current/certs/ca.crt
# Replace the client crt and key with certs/server.crt and certs/server.key if you haven't generated client certs yet
export ETCDCTL_CERT=/var/snap/microk8s/current/certs/extdnsclient/etcd-client.crt
export ETCDCTL_KEY=/var/snap/microk8s/current/certs/extdnsclient/etcd-client.key
ETCDCTL_ENDPOINTS=https://<your server node ip>:12379
```

and then you can run `etcdctl` with whatever you want. For example, `etcdctl put foo bar`, `etcdctl get foo`, `etcdctl del foo` to verify.

To generate the client cert, notionally:
You need to generate a request and then sign it. Here's an example of where microk8s does it:
https://github.com/ubuntu/microk8s/blob/c4f8d0e689dc38b5fbe4ec4258fc61090f1e08a5/microk8s-resources/actions/common/utils.sh#L356


I also ended up using kelsey hightower's kubernetes the hard way, so I mucked around iwth the config file (hopefully an ansible template is coming), and ended up running:
To generate the csr:
`openssl req -config test_etcd_client.conf -new -nodes -keyout extdnsclient/etcd-client.key -out extdnsclient/etcd-client.csr`
Problem is, I'm not sure what `test_etcd_client.conf` looked like at that point 

and then

```
SNAP=/snap/microk8s/current
${SNAP}/usr/bin/openssl x509 -req -sha256 -in etcd-client.csr -CA ../ca.crt  -CAkey ../ca.key -CAcreateserial -out etcd-client.crt -days 365 -extensions etcd_client -extfile test2.conf
```

where at the time I ran that, test2.conf looked like
```
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = etcd_client
distinguished_name = dn

[ dn ]
C = GB
ST = Canonical
L = Canonical
O = Canonical
OU = Canonical
CN = 127.0.0.1

[ req_distinguished_name ]
countryName                = US
countryName_min            = 2
countryName_max            = 2
commonName                 = external-dns-client
0.organizationName         = pik8s

[ etcd_client ]
basicConstraints       = CA:FALSE
extendedKeyUsage       = clientAuth
keyUsage               = digitalSignature, keyEncipherment
```

Again, all of this was a mix of what microk8s is doing and what kelsey hightower recommends in his thing.

That all brings us more or less up to date. Now, I need to figure out how to put secrets into k8s, and then access those secrets by file names. 

The external dns value (it's a helm chart, remember) has this stanza:
```
# optional array of secrets to mount inside coredns container
# possible usecase: need for secure connection with etcd backend
extraSecrets: []
# - name: etcd-client-certs
#   mountPath: /etc/coredns/tls/etcd
# - name: some-fancy-secret
#   mountPath: /etc/wherever
```

So all I need to figure out is how to put the certs and the ca in a secret and mount it, and then update the coredns etcd block to look like
```
  - name: etcd
    parameters: <my internal subdomain>
    configBlock: |-
      stubzones
      path /skydns
      endpoint https://<server host ip>:12379
      tls  /etc/coredns/etcd.crt  /etc/coredns/etcd.key /etc/coredns/etcd_ca.crt
```

This is all adhoc, I intend to do this all this ansible before I'm done, but.

I'm reading [this](https://stackoverflow.com/questions/36887946/how-to-set-secret-files-to-kubernetes-secrets-by-yaml), and so for the template I've got:
```
---
apiVersion: v1    

kind: Secret
metadata:
    name: etcd-client-certs
    namespace: dns
type: Opaque
data:
    etcd.crt: SERVER_CRT
    etcd.key: SERVER_KEY
    ca.crt: CA_CRT
```

And then I ran
```
SERVER_CRT=/var/snap/microk8s/current/certs/extdnsclient/etcd-client.crt
SERVER_KEY=/var/snap/microk8s/current/certs/extdnsclient/etcd-client.key
CA_CRT=/var/snap/microk8s/current/certs/ca.crt
sed "s/SERVER_CRT/`cat $SERVER_CRT|base64 -w0`/g" certs-secret.yml.tmpl | sed "s/SERVER_KEY/`cat $SERVER_KEY|base64 -w0`/g" | sed "s/CA_CRT/`cat $CA_CRT|base64 -w0`/g"
```

Which I think yielded what I want, so gonna apply it now...

Ok, that worked, i think. Not verifying at the moment, but...

[day 13](day_13.md)
