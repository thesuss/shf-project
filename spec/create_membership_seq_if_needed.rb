
# create the sequence for next Member number if needed:
def create_user_membership_num_seq_if_needed
  # see if we can get the next value
  User.connection.execute("CREATE SEQUENCE IF NOT EXISTS membership_number_seq  START 101")
  # see if we can get the next value
  User.connection.execute("SELECT nextval('membership_number_seq')").getvalue(0, 0).to_s
  #    FYI for testing: User.connection.execute("DROP SEQUENCE membership_number_seq;")
end
