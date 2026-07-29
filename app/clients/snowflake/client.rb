module Snowflake
  class Client
    class Error < StandardError; end

    def insert_discourse_event(_row)
      raise NotImplementedError, "Use Snowpipe, a staging bucket, or the approved Snowflake connector"
    end
  end
end
