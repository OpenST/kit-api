module GlobalConstant
  module ContractDetails
    class GatewayComposer

      def self.gas
        return {
          stakeRequests: 1000
        }
      end

      def self.abi
        return [
          {
            "constant": true,
            "inputs": [
              {
                "name": "",
                "type": "bytes32"
              }
            ],
            "name": "stakeRequests",
            "outputs": [
              {
                "name": "stakeVT",
                "type": "uint256"
              },
              {
                "name": "gateway",
                "type": "address"
              },
              {
                "name": "beneficiary",
                "type": "address"
              },
              {
                "name": "gasPrice",
                "type": "uint256"
              },
              {
                "name": "gasLimit",
                "type": "uint256"
              },
              {
                "name": "nonce",
                "type": "uint256"
              }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
          }
        ]
      end
    end
  end
end
