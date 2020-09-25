
#include <string>

namespace kdbmultienv     {

    class Address { // TODO impl class for converting to connect str etc.
        int         portnumber;
        std::string hostname;
        std::string username;
        std::string password;
    };

    // `agentId`observation`reward`done`episode_step`episode_return
    std::vector<TensorNest> derive_multistep_from_result(kdb::Result& result){
        K kres  = result.get_res();
        std::vector<TensorNest> tensors;
        for (int i=0; i< kres->n; i++) {
            K step = kK(kres)[0]; // TODO
            tensors.push_back(TensorNest(std::vector({ // omits agentId
                std::move(TensorNest(torch::tensor(kF(kK(step)[1]), {torch::kFloat64}))), // observation // TODO
                std::move(TensorNest(torch::tensor(kK(step)[2]->f, {torch::kFloat64}))), // reward
                std::move(TensorNest(torch::tensor(kK(step)[3]->g, {torch::kBool}))), // done
                std::move(TensorNest(torch::tensor(kK(step)[4]->f, {torch::kFloat64}))), // episode_step TODO change
                std::move(TensorNest(torch::tensor(kK(step)[5]->f, {torch::kFloat64})))  // episode_return
                })));
        };
        return tensors;
    };

    class MultiEnv
    {
    public:
        MultiEnv(/* args */);
        ~MultiEnv();

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
    
    MultiEnv::MultiEnv(/* args */)
    {
    }

    MultiEnv::Step(/* args */)
    {
    }
    
    MultiEnv::~MultiEnv()
    {
    }
    

    
}