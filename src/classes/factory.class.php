<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


/**
 * @author marce
 *
 */

abstract class Factory {
	static private $m_indice=0;
	/**
	 *
	 * istanzia l'oggetto e lo mette in cache.
	 *
	 * @param $type
	 * @return unknown_type
	 */
	static function crea($classe, $codice=null, $cache=true) {
		if (is_null($codice) || strlen($codice) == 0) {
			if (CACHE && $cache) {
				if (isset($_SESSION["CACHE"][$classe][0])) {
					#DEBUG("Oggetto in cache.");
					return unserialize($_SESSION["CACHE"][$classe][0]);
				}
			}
			#DEBUG("Oggetto nuovo ($classe).");
			$obj = new $classe;
			$obj->init();
			return $obj;
		}
		
		if (CACHE && $cache) {
			if (isset($_SESSION["CACHE"][$classe][$codice])) {
				#DEBUG("pescato ".$classe."($codice))";
				return unserialize($_SESSION["CACHE"][$classe][$codice]);
			}
		}
		$obj = new $classe;
		$obj->loadFromCode($codice);
		if (CACHE || $cache)
			$_SESSION["CACHE"][$classe][$codice] = serialize($obj);
		#DEBUG("creato ".$classe."($codice)");
		return $obj;	
	}
	
	/**
	 *
	 * salva l'oggetto e aggiorna la cache.
	 *
	 * @param $type
	 * @return unknown_type
	 */
	static function salva($oggetto) {
		if (!is_object($oggetto))
			return false;
			
		if (strlen($oggetto->id()) > 0 && strlen($oggetto->code()) > 0) # UPDATE
			$res = $oggetto->update();
		else
			$res = $oggetto->insert();
			
		if ($res) {
			if (CACHE)
				$_SESSION["CACHE"][get_class($oggetto)][$oggetto->code()] = serialize($oggetto);
			self::pulisci(get_class($oggetto));
		}
		
		return $res;
	}
	
	/**
	 *
	 * Crea una copia identica dell'oggetto, azzerando IDENT e CODE.
	 *
	 * @param $type
	 * @return unknown_type
	 */
	static function clona($oggetto) {
		if (!is_object($oggetto))
			return false;

		$clone = unserialize(serialize($oggetto));
		$clone->set("ident", "");
		$clone->set("code", "");
		$clone->clona();

		$_SESSION["CACHE"][get_class($oggetto)][0] = serialize($clone);

		return $clone;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/**
	 *
	 * aggiorna la cache con l'oggetto.
	 *
	 */
	static function memorizza($oggetto) {
		if (!is_object($oggetto))
			return false;

		if (is_object($oggetto->code()))
			$locazione = $oggetto->code()->code();
		elseif (strlen($oggetto->code()) > 0)
			$locazione = $oggetto->code();
		else
			$locazione = 0;

		#DEBUG("Memorizzato in ['CACHE'][".get_class($oggetto)."][$locazione]");
		$_SESSION["CACHE"][get_class($oggetto)][$locazione] = serialize($oggetto);
		return true;
	}
	
	/**
	 *
	 * ritorna l'oggetto memorizzato in cache
	 *
	 */
	static function leggi($classe) {
		if (!isset($_SESSION["CACHE"][$classe][0]))
			return false;
		
		return unserialize($_SESSION["CACHE"][$classe][0]);
	}
	
	/**
	 *
	 * elimina l'oggetto dalla cache.
	 *
	 */
	static function pulisci($classe, $code=0) {
		if (!isset($_SESSION["CACHE"][$classe][$code]))
			return false;
		unset($_SESSION["CACHE"][$classe][$code]);
		return true;
	}




	/**
	 *
	 * mette un oggetto in attesa di convalida durante una transazione.
	 *
	 */
	static function attesa($oggetto) {
		if (!is_object($oggetto))
			return false;

		$indice = self::$m_indice;

		$_SESSION["OGGETTI_ATTESA_CONVALIDA"][$indice] = array(
			'classe' => get_class($oggetto),
			'code' => $oggetto->code()
		);

		self::$m_indice++;

		return true;
	}

	/**
	 *
	 * mette un oggetto in attesa di convalida durante una transazione.
	 *
	 */
	static function conferma($esito) {
		if (isset($_SESSION["OGGETTI_ATTESA_CONVALIDA"])) {
			if ($esito === false) {
				foreach($_SESSION["OGGETTI_ATTESA_CONVALIDA"] as $indice => $oggetto) {
					$obj = Factory::crea($oggetto['classe'], $oggetto['code']);
					$obj->set($obj->identity(), "");
					Factory::memorizza($obj);
				}
			}
			unset($_SESSION["OGGETTI_ATTESA_CONVALIDA"]);
			self::$m_indice = 0;
		}
		return;
	}
}