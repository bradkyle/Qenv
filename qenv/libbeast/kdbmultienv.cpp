
#include <string>

namespace kdbmultienv     {

    struct Address { // TODO impl class for converting to connect str etc.
        int         portnumber;
        std::string hostname;
        std::string username;
        std::string password;
    };

    struct EnvConfig {

    };

    class MultiEnvClient
    {
    private:
        /* data */
    public:
        MultiEnvClient(/* args */);
        ~MultiEnvClient();
    };
    
    MultiEnvClient::MultiEnvClient(/* args */)
    {
    }
    
    MultiEnvClient::~MultiEnvClient()
    {
    }
    

    
}