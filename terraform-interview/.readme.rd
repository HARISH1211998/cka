create_before_destroy -> Creates the new resource before destroying the old one to avoid downtime.
prevent_destroy -> Prevents accidental deletion of the resource (Terraform will throw an error).
ignore_changes -> Tells Terraform to ignore changes to specific attributes during apply.
replace_triggered_by -> Forces replacement when the specified resource or attribute changes.