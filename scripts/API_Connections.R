# Here I am going to set up the connections to the APIs that I will be using in this project. 
# I will be using the following APIs:

# OECD CAPMF API




# CPDB API: for this one I will need to use the reticulate pakage
install.packages("reticulate")
library(reticulate)

# Install the Python package 
py_install("cpdb-api")

# Import the Python library
cpdb <- import("cpdb_api")

# Initialize the request object
r <- cpdb$request$Request()

# Apply filters (using the example from the api docs for now)
r$set_country("IND")
r$set_decision_date(2010)
r$set_policy_status("In force")
r$add_sector("Electricity and heat")
r$add_sector("Coal")
r$add_policy_instrument("Energy and other taxes")
r$add_mitigation_area("Renewables")

# Issue the request
df <- r$issue()

print(head(df))
