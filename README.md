# qizoom
some handy scripts for processing zoom meeting room registration

## Prerequists
- a zoom account 
- create a [zoom jwt app](https://marketplace.zoom.us/develop/create)
- create a meeting room and make it requires regstration.

### Environemnt
- any linux distrubtions.  for Mac users, please install [gawk](https://formulae.brew.sh/formula/gawk)
- [jq](https://stedolan.github.io/jq/) (I've tested it on jq 1.5 only)

## Run 
- Get the JWT token from [zoom app marketplace](https://marketplace.zoom.us/develop/apps), then set it as an environment variable.
  
  ```
  $ export ZOOMAT={the_content_of_jtw_token}
  ```

- Prepare the input csv file, see the csv file in "examples" for reference.
- Convert the csv file to json file then group the resgitrants by languages and partition to 30 each (zoome api can only take 30 registrants at a time)

  ```
  $ cd bin
  $ ./sort_and_break.sh {path_to_input_file} {output_dir}
  ```

- Call zoom api to add the registrants

  ```
  $ ./add_and_approve.sh {meeting_id}  {output_dir} {language}  > {logname}.log

  ## open another terminal and tail the log
  $ tail -f {logname}.log
  ```


