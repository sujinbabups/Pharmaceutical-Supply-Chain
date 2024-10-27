# #!/bin/bash

echo "------------Register the ca admin for each organization—----------------"

docker compose -f docker/docker-compose-ca.yaml up -d
sleep 3

sudo chmod -R 777 organizations/

echo "------------Register and enroll the users for each organization—-----------"

chmod +x registerEnroll.sh

./registerEnroll.sh
sleep 3

echo "—-------------Build the infrastructure—-----------------"

docker compose -f docker/docker-compose-org4.yaml up -d
sleep 3

echo "-------------Generate the genesis block—-------------------------------"

export FABRIC_CFG_PATH=${PWD}/config

export CHANNEL_NAME=pharmachain

configtxgen -profile ThreeOrgsChannel -outputBlock ${PWD}/channel-artifacts/${CHANNEL_NAME}.block -channelID $CHANNEL_NAME
sleep 2

echo "------ Create the application channel------"

export ORDERER_CA=${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/msp/tlscacerts/tlsca.pharma.com-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/server.crt

export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/server.key

osnadmin channel join --channelID $CHANNEL_NAME --config-block ${PWD}/channel-artifacts/$CHANNEL_NAME.block -o localhost:7053 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
sleep 2

osnadmin channel list -o localhost:7053 --ca-file $ORDERER_CA --client-cert $ORDERER_ADMIN_TLS_SIGN_CERT --client-key $ORDERER_ADMIN_TLS_PRIVATE_KEY
sleep 2

export FABRIC_CFG_PATH=${PWD}/peercfg
export CORE_PEER_LOCALMSPID=ManufacturerMSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/users/Admin@manufacturer.pharma.com/msp
export CORE_PEER_ADDRESS=localhost:7051
export MANUFACTURER_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/ca.crt
export WHOLESALER_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/ca.crt
export PHARMACIES_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/ca.crt
export REGULATOR_PEER_TLSROOTCERT=${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/ca.crt
sleep 2

echo "—---------------Join Manufacturer peer to the channel—-------------"

echo ${FABRIC_CFG_PATH}
sleep 2
peer channel join -b ${PWD}/channel-artifacts/${CHANNEL_NAME}.block
sleep 3

echo "-----channel List----"
peer channel list

echo "—-------------Manufacturer anchor peer update—-----------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json >config.json

cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.ManufacturerMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.manufacturer.pharma.com","port": 7051}]},"version": "0"}}' config_copy.json >modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..

peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --tls --cafile $ORDERER_CA
sleep 1

echo "—---------------package chaincode—-------------"

peer lifecycle chaincode package chainPharma.tar.gz --path ${PWD}/../Chaincode/Pharma-Chain --lang node --label chainPharma.0
sleep 1

echo "—---------------install chaincode in Manufacturer peer—-------------"

peer lifecycle chaincode install chainPharma.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled
sleep 1

export CC_PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid chainPharma.tar.gz)

echo "—---------------Approve chaincode in Manufacturer peer—-------------"

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --channelID $CHANNEL_NAME --name Pharma-Chain --version 1.0 --collections-config ../Chaincode/Pharma-Chain/collection-pharma.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent



export CORE_PEER_LOCALMSPID=WholesalerMSP
export CORE_PEER_ADDRESS=localhost:9051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/users/Admin@wholesaler.pharma.com/msp

echo "—---------------Join wholesaler peer to the channel—-------------"

peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1
peer channel list

echo "—-------------wholesaler anchor peer update—-----------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json >config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.WholesalerMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.wholesaler.pharma.com","port": 9051}]},"version": "0"}}' config_copy.json >modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..

peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --tls --cafile $ORDERER_CA
sleep 1

echo "—---------------install chaincode in wholesaler peer—-------------"

peer lifecycle chaincode install chainPharma.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled

echo "—---------------Approve chaincode in wholesaler peer—-------------"

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --channelID $CHANNEL_NAME --name Pharma-Chain --version 1.0 --collections-config ../Chaincode/Pharma-Chain/collection-pharma.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent



export CORE_PEER_LOCALMSPID=PharmaciesMSP
export CORE_PEER_ADDRESS=localhost:10051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/users/Admin@pharmacies.pharma.com/msp

echo "—---------------Join pharmacies peer to the channel—-------------"

peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1
peer channel list

echo "—-------------pharmacies anchor peer update—-----------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json >config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.PharmaciesMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.pharmacies.pharma.com","port": 10051}]},"version": "0"}}' config_copy.json >modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..

peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --tls --cafile $ORDERER_CA
sleep 1

peer channel getinfo -c $CHANNEL_NAME

echo "—---------------install chaincode in Pharmacy peer—-------------"

peer lifecycle chaincode install chainPharma.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled

echo "—---------------Approve chaincode in Pharmacy peer—-------------"

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --channelID $CHANNEL_NAME --name Pharma-Chain --version 1.0 --collections-config ../Chaincode/Pharma-Chain/collection-pharma.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 1

export CORE_PEER_LOCALMSPID=RegulatorsMSP
export CORE_PEER_ADDRESS=localhost:12051
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/regulators.pharma.com/users/Admin@regulators.pharma.com/msp

echo "—---------------Join regulators peer to the channel—-------------"

peer channel join -b ${PWD}/channel-artifacts/$CHANNEL_NAME.block
sleep 1
peer channel list

echo "—-------------regulators anchor peer update—-----------"

peer channel fetch config ${PWD}/channel-artifacts/config_block.pb -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
sleep 1

cd channel-artifacts

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq '.data.data[0].payload.data.config' config_block.json >config.json
cp config.json config_copy.json

jq '.channel_group.groups.Application.groups.RegulatorsMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "peer0.regulators.pharma.com","port": 12051}]},"version": "0"}}' config_copy.json >modified_config.json

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output config_update.pb

configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb

cd ..

peer channel update -f ${PWD}/channel-artifacts/config_update_in_envelope.pb -c $CHANNEL_NAME -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --tls --cafile $ORDERER_CA
sleep 1




echo "—---------------install chaincode in Regulator peer—-------------"

peer lifecycle chaincode install chainPharma.tar.gz
sleep 3

peer lifecycle chaincode queryinstalled

echo "—---------------Approve chaincode in Regulator peer—-------------"

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --channelID $CHANNEL_NAME --name Pharma-Chain --version 1.0 --collections-config ../Chaincode/Pharma-Chain/collection-pharma.json --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile $ORDERER_CA --waitForEvent
sleep 1

echo "—---------------Commit chaincode in Regulator peer—-------------"
peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME --name Pharma-Chain --version 1.0 --sequence 1 --collections-config ../Chaincode/Pharma-Chain/collection-pharma.json --tls --cafile $ORDERER_CA --output json

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.pharma.com --channelID $CHANNEL_NAME --name Pharma-Chain --version 1.0 --sequence 1 --collections-config ../Chaincode/Pharma-Chain/collection-pharma.json --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $MANUFACTURER_PEER_TLSROOTCERT --peerAddresses localhost:9051 --tlsRootCertFiles $WHOLESALER_PEER_TLSROOTCERT --peerAddresses localhost:10051 --tlsRootCertFiles $PHARMACIES_PEER_TLSROOTCERT --peerAddresses localhost:12051 --tlsRootCertFiles $REGULATOR_PEER_TLSROOTCERT
sleep 1

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name Pharma-Chain --cafile $ORDERER_CA