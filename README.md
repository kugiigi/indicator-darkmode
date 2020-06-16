# What is this?
This is a proof of concept for an indicator to switch between Ambiance and Suru Dark theme.

This is based from the amazing work of **Brian Douglass** for [Indicator Weather](https://gitlab.com/bhdouglass/indicator-weather)
Thank you **Brian**!

# What does it exactly do?
It modifies the theme in the config file "/home/phablet/.config/ubuntu-ui-toolkit/theme.ini"

# How does it work?
Enabling Dark Mode from the indicator will switch to the theme "Suru Dark". Disabling it will revert back to "Ambiance". There is also an option to switch the theme automatically based on the time.

# Anything else?
- The theme change won't take effect on currently open apps until they are restarted. 
- Time accuracy for automatically switching to a theme will be based on the set time interval for checking the time.
- Suru Dark theme support varies across apps. There are apps that just works while some will only have partial support and some won't even respect it.

# How to compile?
You can use [clickable](https://clickable-ut.dev) to compile.
