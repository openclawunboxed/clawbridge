# auth and billing

this is the anthropic split this repo assumes.

- api key is still the clearest production path for long-lived gateway hosts and explicit server-side billing control.
- claude cli reuse on the same host is treated by openclaw as sanctioned again for this integration.
- legacy anthropic token profiles are still honored at runtime if you already have them.
- openclaw's model-provider docs also note a practical split between api key and the openclaw claude-login path with extra usage under the subscription path.

what this means in practice

for a serious always-on host:
- prefer api key if you want the clearest billing story and the least ambiguity.

for a builder already living in claude code on the same box:
- claude cli reuse is a strong fit and is the path this repo is built around.

for an older setup that already uses token auth:
- keep it only if you understand the tradeoff and have no better reason to migrate yet.

what this repo is not trying to do

- it is not defending legacy token auth as the center of a fresh install.
- it is not claiming claude code only works with a claude subscription.
- it is not claiming remote control or channels work with console or api key auth.
