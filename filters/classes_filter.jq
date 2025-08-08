# https://stackoverflow.com/a/54009919
def to24h:
    (capture("(?<pre>.*)(?<h>[01][0-9])(?<m>:[0-5][0-9]) *(?<midi>[aApP])[mM](?<post>.*)") //
     capture("(?<pre>.*)(?<h>[0-9])(?<m>:[0-5][0-9]) *(?<midi>[aApP])[mM](?<post>.*)"))

  | (.midi|ascii_upcase) as $midi
  | .pre + (if $midi == "A" then .h else "\(12+(.h|tonumber|.%12))" end) + .m + .post ;

[.[].classes.data[] | walk(
	if type=="object" and has("start_time") then
	with_entries(
		if .key == "start_time" or .key == "end_time" then
			.value |= to24h // .
		else
			.
		end
	)
	else
		.
	end
)]
