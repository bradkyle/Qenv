
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

    class Action {

    };

    class MultiAction {

    };

    class Step {

    }; // Todo to nest

    class MultiStep {

    }; // TODO to nest

    class Status {

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

        kdbmultienv::Status Close(){

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