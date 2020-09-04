<?php

use \Jacwright\RestServer\RestException;

// Tiago Marques DDM - A Nº 45089

class TestController
{
    /**
     * Returns a JSON string object to the browser when hitting the root of the domain
     *
     * @url GET /dab
     */
    public function test()
    {
        return "Hello World";
    }

    /**
     * @url POST /equilibrio
     */
    public function EquilibrioContacto(){
        
		$res;
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

		$nome = $_POST['nome'];
        $apelido = $_POST['apelido']; 
        $telemovel = $_POST['telemovel'];
        $localidade = $_POST['localidade']; 
		
        $res = $conn->query("SELECT * FROM contatos where nome='$nome' AND apelido='$apelido' AND telemovel='$telemovel' AND localidade='$localidade'");

        $rows = array();
        while($r = $res->fetch_array(MYSQLI_ASSOC)){
            $rows[] = $r;
        }

		if (count($rows) == 0){
			$sql = "INSERT INTO contatos (nome, apelido, telemovel, localidade) VALUES ('$nome', '$apelido', '$telemovel', '$localidade')";
			if ($conn->query($sql) === TRUE) {
				echo "Sucesso!";
			} else {
				echo "Erro: " . $sql . "<br>" . $conn->error;
			}			
		}
         $conn->close();
    } 
	
	 /**
     * @url POST /equilibriolembrete
     */
    public function EquilibrioLembreteContacto(){
        
		$res;
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

		$idcontacto = $_POST['idcontacto'];
        $titulo = $_POST['titulo']; 
        $conteudo = $_POST['conteudo'];
		
        $res = $conn->query("SELECT * FROM lembrete where idcontacto='$idcontacto' AND titulo='$titulo' AND conteudo='$conteudo'");

        $rows = array();
        while($r = $res->fetch_array(MYSQLI_ASSOC)){
            $rows[] = $r;
        }

		if (count($rows) == 0){
			$sql = "INSERT INTO lembrete (idcontacto, titulo, conteudo) VALUES ('$idcontacto', '$titulo', '$conteudo')";
			
			if ($conn->query($sql) === TRUE) {
				echo "Sucesso!";
			} else {
				echo "Erro: " . $sql . "<br>" . $conn->error;
			}	
		}
        $conn->close();		
    } 

  /**
     *
     * @url GET /contactos
     * @url GET /contactos/$id
    */
    public function getAll($id = null){

        $res;
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

        if(!$id){
            $res = $conn->query("SELECT * FROM contatos");
        }else {
            $res = $conn->query("SELECT * FROM contatos where id=$id");
        }

        $rows = array();
        while($r = $res->fetch_array(MYSQLI_ASSOC)){
            $rows[] = $r;
        }
        $conn->close();

        echo json_encode($rows);
    }
	
	/**
     *
     * @url GET /contactossearch/$tipo/$valor
    */
    public function getAllSearch($tipo = null, $valor = null){

        $res;
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

        if($tipo != null && $valor != null){ 
			if($tipo == 0){ 
			   $res = $conn->query("SELECT * FROM contatos WHERE nome LIKE '%$valor%'");
			}else if($tipo == 1){ 
			   $res = $conn->query("SELECT * FROM contatos WHERE apelido LIKE '%$valor%'");
			}else if($tipo == 2){ 
			   $res = $conn->query("SELECT * FROM contatos WHERE telemovel LIKE '%$valor%'");
			}else if($tipo == 3){ 
			   $res = $conn->query("SELECT * FROM contatos WHERE localidade LIKE '%$valor%'");
			}else{
			   $res = $conn->query("SELECT * FROM contatos");
			}
        
        $rows = array();
        while($r = $res->fetch_array(MYSQLI_ASSOC)){
            $rows[] = $r;
        }
        $conn->close();

        echo json_encode($rows);
		}
    }
	
	/**
     *
     * @url GET /lembretes
     * @url GET /lembretes/$id
    */
    public function getAllLembretes($id = null){

        $res;
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

        if(!$id){
            $res = $conn->query("SELECT * FROM lembrete");
        }else {
            $res = $conn->query("SELECT * FROM lembrete where id=$id");
        }

        $rows = array();
        while($r = $res->fetch_array(MYSQLI_ASSOC)){
            $rows[] = $r;
        }
        $conn->close();

        echo json_encode($rows);
    }

    /**
     * @url POST /addcontacto
     */
    public function addContacto(){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

		$nome = $_POST['nome'];
        $apelido = $_POST['apelido']; 
        $telemovel = $_POST['telemovel'];
        $localidade = $_POST['localidade']; 
         
		$sql = "INSERT INTO contatos (nome, apelido, telemovel, localidade) VALUES ('$nome', '$apelido', '$telemovel', '$localidade')";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}

    }

   /**
     * @url POST /addlembrete
     */
    public function addLembrete(){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

		$idcontacto = $_POST['idcontacto'];
        $titulo = $_POST['titulo']; 
        $conteudo = $_POST['conteudo'];
         
		$sql = "INSERT INTO lembrete (idcontacto, titulo, conteudo) VALUES ('$idcontacto', '$titulo', '$conteudo')";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}

    }


    /**
     * @url POST /update/$id
     */
    public function updateContacto($id){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

		$nome = $_POST['nome'];
        $apelido = $_POST['apelido']; 
        $telemovel = $_POST['telemovel'];
        $localidade = $_POST['localidade']; 
         
		$sql = "UPDATE contatos SET nome='$nome', apelido='$apelido', telemovel='$telemovel', localidade='$localidade' WHERE id='$id'";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}
    }
	
	 /**
     * @url POST /updatelembrete/$id
     */
    public function updateLembrete($id){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');

		$idcontacto = $_POST['idcontacto'];
        $titulo = $_POST['titulo']; 
        $conteudo = $_POST['conteudo']; 
         
		$sql = "UPDATE lembrete SET idcontacto='$idcontacto', titulo='$titulo', conteudo='$conteudo' WHERE idlembrete='$id'";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}
    }


    /**
     * @url DELETE /delete/$id
     */
    public function deleteContacto($id){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');
         
		$sql = "DELETE FROM contatos WHERE id = '$id'";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}
    }
	
	/**
     * @url DELETE /deletelembrete/$id
     */
    public function deleteLembrete($id){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');
         
		$sql = "DELETE FROM lembrete WHERE idlembrete = '$id'";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}
    }
	
	/**
     * @url DELETE /deletevarioslembrete/$id
     */
    public function deletevariosLembrete($id){
        
        $conn = new mysqli('localhost', 'root', 'internet', 'agendaios');
         
		$sql = "DELETE FROM lembrete WHERE idcontacto = '$id'";
		
		if ($conn->query($sql) === TRUE) {
			echo "Sucesso!";
		} else {
			echo "Erro: " . $sql . "<br>" . $conn->error;
		}
    }

    /**
     * Throws an error
     * 
     * @url GET /error
     */
    public function throwError() {
        throw new RestException(401, "Empty password not allowed");
    }
}
