# Base class for errors that can occur during backups and errors used
# by more than one of the Backup and/or BackupMaker class.
# TODO Not a good sign that these are shared; should be distinct.

module ShfConditionError

  class BackupError < StandardError
  end

end
