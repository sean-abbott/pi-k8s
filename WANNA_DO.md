# Lets Encrypt Wildcard Cert
Yay, this CAN be done without running a webserver. 
Notional steps:
* Do this to get the cert: https://dev.to/nabbisen/let-s-encrypt-wildcard-certificate-with-certbot-plo
* But this has to be [renewed](https://dev.to/nabbisen/let-s-encrypt-renew-wildcard-certificate-manually-with-certbot-1jp) every 90 days, so...
* then figure out how to automate the txt update. Parsing it out of the response may be annoying, but then using the dnsimple api looks pretty straight forward
* blog about it, for sure.
* lets encrypt and dnsimple both have go libraries, so hypothetically could write a little go app to do the renewals and update dnsimple

works, but: https://certbot-dns-dnsimple.readthedocs.io/en/stable/

# fedilab / untrack me
https://fedilab.app/
* nitter is another thing that would be cool to run, especially if I can use that to post (which then might mean I could federate to mastodon and twitter)
