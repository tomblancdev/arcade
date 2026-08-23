# sunshine

The stream, Bazzite's own route for Deck images as code (what `ujust
setup-sunshine` does by hand): the LizardByte tap, the `sunshine` brew
package pinned, Bazzite's `sunshine-postinst` for the capability KMS capture
needs and the uinput rule, one config dir on `/srv/screen/sunshine`
(`~/.config/sunshine` points at it: config, pairings, the admin's login),
`sunshine.conf` keys from data (`capture = kms`, `channels`, the base port,
the name), the web UI's credentials set from a secret (no first-run page),
and `arcade-sunshine.service` as a **user unit** of the player's user,
lingering so it answers right after boot. Pairing a client stays a hands
step (the PIN page on the web UI). Contract:
[`defaults/main.yml`](defaults/main.yml).
