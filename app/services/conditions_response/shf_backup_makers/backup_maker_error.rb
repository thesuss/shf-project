# Base class for errors that can occur by BackupMakers

module ConditionsResponse
  module ShfBackupMakers

    class BackupMakerError < ::ConditionsResponse::ConditionsResponseError
    end

    class BackupCommandNotSuccessfulError < BackupMakerError; end

  end
end
