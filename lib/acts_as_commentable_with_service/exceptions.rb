module Acts
  module CommentableWithService
    class RequestException < RuntimeError
    end
    class ServerException < RuntimeError
    end
  end
end
