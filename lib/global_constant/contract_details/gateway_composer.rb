module GlobalConstant
  module ContractDetails
    class GatewayComposer

      def self.gas
        return {
          requestStake: '0x61A80'# 300000
        }
      end

      def self.abi
        return [
          {
            "name": "requestStake",
            "constant": false,
            "inputs": [
              {
                "name": "_stakeVT",
                "type": "uint256"
              },
              {
                "name": "_mintBT",
                "type": "uint256"
              },
              {
                "name": "_gateway",
                "type": "address"
              },
              {
                "name": "_beneficiary",
                "type": "address"
              },
              {
                "name": "_gasPrice",
                "type": "uint256"
              },
              {
                "name": "_gasLimit",
                "type": "uint256"
              },
              {
                "name": "_nonce",
                "type": "uint256"
              }
            ],
            "outputs": [
              {
                "name": "requestStakeHash_",
                "type": "bytes32"
              }
            ],
            "payable": false,
            "stateMutability": "nonpayable",
            "type": "function"
          }
        ]
      end
    end
  end
end
