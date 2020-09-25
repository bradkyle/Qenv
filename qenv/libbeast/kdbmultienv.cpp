
#include <string>

namespace kdbmultienv     {

    class Address { // TODO impl class for converting to connect str etc.
        int         portnumber;
        std::string hostname;
        std::string username;
        std::string password;
    };

    class EnvConfig {

    };

    class MultiAction {

    };

    class MultiStep {

    };

    class MultiEnvClient
    {
    private:
        /* data */
    public:
        MultiEnvClient(/* args */);
        ~MultiEnvClient();

        bool WaitForConnected() {
            
        }

        kdbmultienv::MultiStep Reset(
            kdbmultienv::MultiStep& step){

        }

        kdbmultienv::MultiStep Step(
            kdbmultienv::MultiAction action,
            kdbmultienv::MultiStep& step){
                
        }
    };
    
    MultiEnvClient::MultiEnvClient(/* args */)
    {
    }

    MultiEnvClient::Step(/* args */)
    {
    }
    
    MultiEnvClient::~MultiEnvClient()
    {
    }
    

    
}