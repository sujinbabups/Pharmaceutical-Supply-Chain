#!/bin/bash

function createManufacturer() {
  echo "Enrolling the CA admin for Manufacturer"
  mkdir -p organizations/peerOrganizations/manufacturer.pharma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-manufacturer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-manufacturer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/config.yaml"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/tlsca/tlsca.manufacturer.pharma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/ca"
  cp "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/ca/ca.manufacturer.pharma.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user1"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering org admin"
  set -x
  fabric-ca-client register --caname ca-manufacturer --id.name manufactureradmin --id.secret manufactureradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Peer0 MSP and TLS certificates
  echo "Generating the peer0 MSP"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/msp/config.yaml"

  echo "Generating the peer0 TLS certificates"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls" --enrollment.profile tls --csr.hosts peer0.manufacturer.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer0.manufacturer.pharma.com/tls/server.key"

  # Peer1 MSP and TLS certificates
  echo "Generating the peer1 MSP"
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/msp/config.yaml"

  echo "Generating the peer1 TLS certificates"
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls" --enrollment.profile tls --csr.hosts peer1.manufacturer.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/peers/peer1.manufacturer.pharma.com/tls/server.key"

  echo "Generating the user MSP"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/users/User1@manufacturer.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/users/User1@manufacturer.pharma.com/msp/config.yaml"

  echo "Generating the org admin MSP"
  fabric-ca-client enroll -u https://manufactureradmin:manufactureradminpw@localhost:7054 --caname ca-manufacturer -M "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/users/Admin@manufacturer.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/manufacturer/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/manufacturer.pharma.com/users/Admin@manufacturer.pharma.com/msp/config.yaml"
}


function createWholesaler() {
  echo "Enrolling the CA admin for Wholesaler"
  mkdir -p organizations/peerOrganizations/wholesaler.pharma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-wholesaler --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-wholesaler.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-wholesaler.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-wholesaler.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-wholesaler.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/msp/config.yaml"

  mkdir -p "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem" "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem" "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/tlsca/tlsca.wholesaler.pharma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/ca"
  cp "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem" "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/ca/ca.wholesaler.pharma.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-wholesaler --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user1"
  set -x
  fabric-ca-client register --caname ca-wholesaler --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering org admin"
  set -x
  fabric-ca-client register --caname ca-wholesaler --id.name wholesaleradmin --id.secret wholesaleradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-wholesaler -M "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/msp/config.yaml"

  echo "Generating the peer0 TLS certificates"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-wholesaler -M "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls" --enrollment.profile tls --csr.hosts peer0.wholesaler.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/peers/peer0.wholesaler.pharma.com/tls/server.key"

  echo "Generating the user MSP"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-wholesaler -M "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/users/User1@wholesaler.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/users/User1@wholesaler.pharma.com/msp/config.yaml"

  echo "Generating the org admin MSP"
  fabric-ca-client enroll -u https://wholesaleradmin:wholesaleradminpw@localhost:8054 --caname ca-wholesaler -M "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/users/Admin@wholesaler.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/wholesaler/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/wholesaler.pharma.com/users/Admin@wholesaler.pharma.com/msp/config.yaml"
}

function createPharmacy() {
  echo "Enrolling the CA admin for Pharmacy"
  mkdir -p organizations/peerOrganizations/pharmacies.pharma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-pharmacies --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"
  { set +x; } 2>/dev/null

echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pharmacies.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pharmacies.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pharmacies.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-pharmacies.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/msp/config.yaml"

  mkdir -p "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem" "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem" "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/tlsca/tlsca.pharmacies.pharma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/ca"
  cp "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem" "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/ca/ca.pharmacies.pharma.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-pharmacies --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user1"
  set -x
  fabric-ca-client register --caname ca-pharmacies --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering org admin"
  set -x
  fabric-ca-client register --caname ca-pharmacies --id.name pharmaciesadmin --id.secret pharmaciesadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP" 
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-pharmacies -M "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/msp/config.yaml"

  echo "Generating the peer0 TLS certificates"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-pharmacies -M "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls" --enrollment.profile tls --csr.hosts peer0.pharmacies.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/peers/peer0.pharmacies.pharma.com/tls/server.key"

  echo "Generating the user MSP"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-pharmacies -M "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/users/User1@pharmacies.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/users/User1@pharmacies.pharma.com/msp/config.yaml"

  echo "Generating the org admin MSP"
  fabric-ca-client enroll -u https://pharmaciesadmin:pharmaciesadminpw@localhost:11054 --caname ca-pharmacies -M "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/users/Admin@pharmacies.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/pharmacies/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/pharmacies.pharma.com/users/Admin@pharmacies.pharma.com/msp/config.yaml"


}

function createRegulators() {
  echo "Enrolling the CA admin for Regulators"
  mkdir -p organizations/peerOrganizations/regulators.pharma.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/regulators.pharma.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:12054 --caname ca-regulators --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-regulators.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-regulators.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-regulators.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-12054-ca-regulators.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/regulators.pharma.com/msp/config.yaml"

  mkdir -p "${PWD}/organizations/peerOrganizations/regulators.pharma.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem" "${PWD}/organizations/peerOrganizations/regulators.pharma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/regulators.pharma.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem" "${PWD}/organizations/peerOrganizations/regulators.pharma.com/tlsca/tlsca.regulators.pharma.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/regulators.pharma.com/ca"
  cp "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem" "${PWD}/organizations/peerOrganizations/regulators.pharma.com/ca/ca.regulators.pharma.com-cert.pem"

  echo "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-regulators --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user1"
  set -x
  fabric-ca-client register --caname ca-regulators --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering org admin"
  set -x
  fabric-ca-client register --caname ca-regulators --id.name regulatorsadmin --id.secret regulatorsadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer0 MSP" 
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-regulators -M "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/regulators.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/msp/config.yaml"

  echo "Generating the peer0 TLS certificates"
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:12054 --caname ca-regulators -M "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls" --enrollment.profile tls --csr.hosts peer0.regulators.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/regulators.pharma.com/peers/peer0.regulators.pharma.com/tls/server.key"

  echo "Generating the user MSP"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:12054 --caname ca-regulators -M "${PWD}/organizations/peerOrganizations/regulators.pharma.com/users/User1@regulators.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/regulators.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/regulators.pharma.com/users/User1@regulators.pharma.com/msp/config.yaml"

  echo "Generating the org admin MSP"
  fabric-ca-client enroll -u https://regulatorsadmin:regulatorsadminpw@localhost:12054 --caname ca-regulators -M "${PWD}/organizations/peerOrganizations/regulators.pharma.com/users/Admin@regulators.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/regulators/ca-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/regulators.pharma.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/regulators.pharma.com/users/Admin@regulators.pharma.com/msp/config.yaml"
}

function createOrderer() {
  echo "Enrolling the CA admin for Orderer"
  
  # Create directories for orderer organizations
  mkdir -p organizations/ordererOrganizations/pharma.com

  # Set the CA client home for the orderer organization
  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/pharma.com/

  # Enroll CA admin for the orderer organization
  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Create the config.yaml file for the MSP
  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/pharma.com/msp/config.yaml"

  # Copy the CA cert to MSP, TLSCA, and CA directories
  mkdir -p "${PWD}/organizations/ordererOrganizations/pharma.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/pharma.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/ordererOrganizations/pharma.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/pharma.com/tlsca/tlsca.orderer.pharma.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/pharma.com/ca"
  cp "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/pharma.com/ca/ca.orderer.pharma.com-cert.pem"

  # Register the orderer identity
  echo "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Register the user identity for the orderer org
  echo "Registering user1"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Register the orderer org admin
  echo "Registering org admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordereradmin --id.secret ordereradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Enroll the orderer to generate its MSP
  echo "Generating the orderer MSP"
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/msp" --csr.hosts orderer.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"

  # Ensure the MSP config file is properly copied for the orderer
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/msp/config.yaml"

  # Enroll the orderer to generate its TLS certificates
  echo "Generating the orderer TLS certificates"
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls" --enrollment.profile tls --csr.hosts orderer.pharma.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"
  
  # Move the TLS certs to the appropriate location
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/pharma.com/orderers/orderer.pharma.com/msp/tlscacerts/tlsca.pharma.com-cert.pem"

  # Enroll the user to generate its MSP
  echo "Generating the user MSP"
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma.com/users/User1@orderer.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"

  # Ensure the MSP config file is properly copied for the user
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/pharma.com/users/User1@orderer.pharma.com/msp/config.yaml"

  # Enroll the org admin to generate its MSP
  echo "Generating the org admin MSP"
  fabric-ca-client enroll -u https://ordereradmin:ordereradminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/pharma.com/users/Admin@orderer.pharma.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/orderer/ca-cert.pem"

  # Ensure the MSP config file is properly copied for the org admin
  cp "${PWD}/organizations/ordererOrganizations/pharma.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/pharma.com/users/Admin@orderer.pharma.com/msp/config.yaml"
}





createManufacturer
createWholesaler
createPharmacy
createRegulators
createOrderer
