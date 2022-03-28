pragma solidity <=0.8.13;
pragma experimental ABIEncoderV2;
contract OMS_COVID {


    address OMS ;
    constructor () public {
        OMS=msg.sender;
    }
    mapping (address=>bool) Validacion_CentrosSalud;
    mapping (address=>bool) solicitudValidacion;
    mapping (address=>address) public CentroXContrato;

    event nuevoCentroValidado(address);
    event nuevoContrato (address,address);
    event validacionSolicitada(address);

    address [] public direcciones_contratos_salud;
    address []  solicitantes;

    modifier onlyOMS(address _dir) {
        require(_dir==OMS,"solo la OMS tiene este permiso");
        _;
    }

    //funcion para validar nuevos centros de salud

    function validarCenttro(address _dir) public onlyOMS(msg.sender) {
        Validacion_CentrosSalud[_dir]=true;
        emit nuevoCentroValidado(_dir);
        
    }

    function factoryCentroSalud() public {
        require(Validacion_CentrosSalud[msg.sender]==true,"no tenes permisos de la OMS");
        address contratoCentroSalud=address(new contratoCentro(msg.sender));
        direcciones_contratos_salud.push(contratoCentroSalud);
        CentroXContrato[msg.sender]=contratoCentroSalud;
        emit nuevoContrato(msg.sender,contratoCentroSalud);
    }

    //funcion para solicitar acceso a la oms
    function solicitarPermiso() public {
        require(solicitudValidacion[msg.sender]==false,"ya solicitaste permiso");
        solicitudValidacion[msg.sender]=true;
        solicitantes.push(msg.sender);
        emit validacionSolicitada(msg.sender);
    }

    function verSolicitudes() public view onlyOMS(msg.sender) returns (address [] memory){
        return solicitantes;
    }

}
contract contratoCentro {
    address public direccionCentroSalud;
    address public direccionContrato;
    
    constructor (address _dir) public {
        direccionCentroSalud=_dir;
        direccionContrato=address(this);
    }

    mapping (bytes32=>resultadoCovid) resultadosCovid;

    struct resultadoCovid{
        bool diagnostico;
        string ipfs;
    }

    event nuevoResultado(bool,string);

    modifier onlyCentro(address _dir ) {
        require (_dir==direccionCentroSalud, "No tienes permiso para ejecutar esto");
        _;
    }
    // FFX11 true QmamrxitbYvEQmWYWfqXDbk9L7eSynbuRo3YSCabq4Zpsn

    function resultadosPruebaCovid ( string memory _idPersona,bool _resultadoCOVID,string memory _codigoIPFS) public onlyCentro(msg.sender) {
        bytes32 hashId=keccak256(abi.encodePacked(_idPersona));
        resultadosCovid[hashId]=resultadoCovid(_resultadoCOVID,_codigoIPFS);
        emit nuevoResultado(_resultadoCOVID,_codigoIPFS);
    }
    
    function verResultados(string memory _id) public view returns(string memory,string memory) {
        bytes32 hashId=keccak256(abi.encodePacked(_id));
        string memory resultadoPrueba;
        /* require() */
        if (resultadosCovid[hashId].diagnostico==true) {
            resultadoPrueba="Resultado: POSITIVO en COVID-19";
        } else {
            resultadoPrueba="Resultado: NEGATIVO";
        }
        return (resultadoPrueba, resultadosCovid[hashId].ipfs);
    }

}