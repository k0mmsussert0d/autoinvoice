# autoinvoice
Bash script for automatically generating and sending RTF invoice documents.

## Instalation
- Clone the repository  
`git clone https://github.com/k0mmsussert0d/autoinvoice`
- Run setup script  
`./install.sh`  
*You need to have `sudo` installed. If you can't perform root actions on your account or your Linux doesn't support apt package managment, make sure you have all the dependencies installed (line 7 in install.sh)*
- Add this task to your **daily** crontab:  
`cd /path/to/the/repository && ./run.sh`
*Script is using relative paths in many ways, and it have to be executed within its own directory!*  
**You also need to have `mutt` configured and working.**

## Usage
To perform a full execution, run `run.sh` file within its own directory. This is very important to always run this script in this way: `./run.sh`
Optional arguements are:
- `--no-live` - invoices will be generated and saved to the `output` directory, but not sent to the recepients,
- `--force` - invoices will be generated even if today date doesn't match `on_day` config variable

You can also test the documents generating system separately, running:  
`./generate.sh [INPUT] [OUTPUT] [CONFIG_FILE]`

## Configuration
### Configs management
Every config file should be put in `conf-available` directory. Each config you want to be used during an execution of `run.sh` should be put or linked in `conf-enabled` directory. This concept is well-known and used in other software, e.g. Apache2.  
  
Basically, to enable a config, go to `conf-enabled` and perform:  
`ln -s ../conf-avaiable/yourconfigname yourconfigname`  
  
### Defining variables
Inside a config file you can specify any variables you want. The syntax is:  
`variable_name=variable`  
or  
`variable_name="variable"`  
Do not use any use any kind of quotation mark symbol except for `"`!
  
If `variable_name` with `#` preceading can be found in a template file, it'll be replaced.
For e.g., if you want to have `address` field on your document, have `#address` in a RTF file and `address="something"` in a config file.
  
There are some special variables, crucial to normal script execution:  
- `invoice_no` - format of an invoice number. These variables could be useful for creating it:
  - `$nr` - a full number generated with `print_no` and `ordinal_no` (look below)
  - `$y` - this date year (e.g. `2018`)
  - `$m` - this date month (e.g. `5`)
  - `$m_long` - this date month 2-chars-long (e.g. `05`)
  - `$d` - this date day (e.g. `9`)
  - `$today` - today date (e.g. 5-05-2018)  
  You can also use any other variables specified in the config file **before** `invoice_no` or avaiable in your shell session.  
- `print_no` - width of invoice number. Essentially, replaces `x` in this `printf` function: `printf( "%0xd", num );`
- `ordinal_no` - an invoice number. Defines a `num` variable in a function shown above. Script will look for this number in `data/numbers_month` and `data/numbers_year` file. If there's a match, the number in a file is incremented after usage. Variables in `numbers_month` are reset every 1st of each month. Variables in `numbers_year` are reset every 1st of each year.
- `deadline_date` - defines how many days does the buyer have to pay the invoice. If `$today=2018-07-03` and `deadline_date=7`, then `#deadline_date` in a destination document will be replaced with `2018-07-10`.  
  
### Defining items
TBC
