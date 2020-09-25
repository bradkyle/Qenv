
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
        private:

        public:
            struct Action {

            };
    };

    class MultiStep {
        private:

        public:
            struct Step {

            };

    }; // TODO to nest

    class Status {

    }; // todo ok, get from grpc

    class MultiEnvClient
    {
    public:
        MultiEnvClient(/* args */);
        ~MultiEnvClient();

        bool WaitForConnected() {
            
        } // TODO get from grpc

        kdbmultienv::MultiStep Reset(
            kdbmultienv::MultiStep& step){

        }

        kdbmultienv::MultiStep Step(
            kdbmultienv::MultiAction action,
            kdbmultienv::MultiStep& step){
                
        }

        kdbmultienv::Status Close(){

        }
    private:
        const kdbmultienv::Address env_server_address_;
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