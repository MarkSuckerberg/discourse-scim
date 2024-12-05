# Discourse SCIM Plugin

A simple plugin that adds SCIM endpoints to [Discourse](https://discourse.org/).

The plugin is currently under development, not everything might work.

SCIM is a standard proposed by the IETF through [RFC7644](https://www.rfc-editor.org/rfc/rfc7644) and
[RFC7643](https://www.rfc-editor.org/rfc/rfc7643) which aims to provide solution for user/group management through a
simple Rest API.

The development of this plugin was funder by NGI via NLNet, you can read the proposal and about related work
[in our forum here](https://forum.indiehosters.net/t/candidature-ngi-nlnet-privacy-trust-enhancing-technologies/4715).

## To install the plugin

The easiest way to install the plugin to your running Discourse instance is to clone this repository and link or copy
the main folder of this repository to the `plugins/` folder in the Discourse code:

```
$ git clone https://forge.libre.sh/libre.sh/discourse-scim.git
$ cd discourse
$ ln -s ../discourse-scim plugins/
```

The plugin is enabled automatically when you (re)start the Discourse instance.

## Query the SCIM endpoints

To query the SCIM endpoints you have to create an API key first. You can have a global API key for all users or a
granular (scoped) API key for all users as described here:

https://meta.discourse.org/t/create-and-configure-an-api-key/230124

Please use the scope `scim`. Currently you have to allow access to all endpoints together.

Then to query all users with curl for example:

```
$ curl -H 'Authorization: Bearer <your_api_key>' -H 'Content-Type: application/scim+json' -v http://localhost:4200/scim_v2/Users

```

## Funding

This project is funded through [NGI0 Entrust](https://nlnet.nl/entrust), a fund established by [NLnet](https://nlnet.nl) with financial support from the European Commission's [Next Generation Internet](https://ngi.eu) program. Learn more at the [NLnet project page](https://nlnet.nl/project/Libre.sh-SCIM).

[<img src="https://nlnet.nl/logo/banner.png" alt="NLnet foundation logo" width="20%" />](https://nlnet.nl)
[<img src="https://nlnet.nl/image/logos/NGI0_tag.svg" alt="NGI Zero Logo" width="20%" />](https://nlnet.nl/entrust)
