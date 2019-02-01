module GlobalConstant
  module ContractDetails
    class BrandedToken

      def self.gas
        return {}
      end

      def self.abi
        return [
          {
            "constant": true,
            "inputs": [
              {
                "name": "_valueTokens",
                "type": "uint256"
              }
            ],
            "name": "convertToBrandedTokens",
            "outputs": [
              {
                "name": "",
                "type": "uint256"
              }
            ],
            "payable": false,
            "stateMutability": "view",
            "type": "function"
          },
          {
            "constant": true,
            "inputs": [
              {
                "name": "_brandedTokens",
                "type": "uint256"
              }
            ],
            "name": "convertToValueTokens",
            "outputs": [
              {
                "name": "",
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
