# OASIS

OASIS stands for "obviously awesome student information system". The intent is to create an open source student information system that has all the features that a school needs
with the ability to extend with plugins to all that a school might want.

# Commerical Use
Please contact catdevman before doing any commerical use.
OASIS currently does not have a license so it should be consider
viewable source but you have no license to use it commerically.
I am trying to figure out if I have a business model around plugins
and support so I want to leave it open to my own personal commerical use for now.
If a school wants to run it on their own that is their choice but I give no guarantee.

# TODO
- [ ] When plugins boot up keep track of all route registered so far and make sure that it gracefully handles duplicated routes
    - [x] perhaps plugins should have a load order that is respected??? Did this with a config file that defines command path and route prefix
