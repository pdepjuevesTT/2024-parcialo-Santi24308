class Persona{
  var property metodosDePago  //una Lista con metodos 
  var property objetos //lista
  var property formaDePagoPreferida
  var property trabajo  


  method puedeComprarConMetodoPreferido(objeto) = objeto.valor() <= formaDePagoPreferida.dineroDisponible()

  method comprarUnObjeto(objeto) {
    //if(self.puedeComprarConMetodoPreferido(objeto))      lo tuve que comentar porque luego al ser el super no reconoce el "if" y cuando quiero hacer el 
    //"else" para que una persona comulsiva use otro metodo me rompe el codigo
      objetos.add(objeto)
      formaDePagoPreferida.efectuarCompraPor(objeto.valor()) 
  }

  method dineroEnEfectivo() = metodosDePago.find({metodo => metodo.efectivo()}).dineroDisponible()

  method tarjetasDeCreditos() = metodosDePago.filter({metodo => !metodo.debitoInstantaneo()})

  method deudasDelMes() = self.tarjetasDeCreditos().map({tarjeta => tarjeta.deudaTotalPorMes()})

  method totalDeudasDelMes() = self.deudasDelMes().sum() 


  method cobrarSueldo(){
    const remanante = trabajo.sueldoActual() - self.totalDeudasDelMes()
    if(remanante > 0 ){
        self.tarjetasDeCreditos().forEach({tarjeta => tarjeta.pagarDeudaDelMes()})
        self.agregarEfectivo(remanante)}
    else self.pagarDeudasQueLeAlcancen(trabajo.sueldoActual())
  } 

  method pagarDeudasQueLeAlcancen(unDinero) {
      self.tarjetasDeCreditos().filter({tarjeta => tarjeta.deudaTotalPorMes() < unDinero}).forEach({tarjeta => tarjeta.pagarDeudasDelMes()})
  } 

  method agregarEfectivo(unValor){ metodosDePago.find({metodo => metodo.efectivo()}).recibirDineroPor(unValor)}


  method cantidadDeObjetosQueTiene() = self.objetos().size() 

  method formaDePagoPreferida(nuevaForma) {
    if(metodosDePago.contains(nuevaForma)) 
      formaDePagoPreferida = nuevaForma
    else 
      throw new DomainException(message ="No existe esa forma de pago")
  }
} 



object fecha {
  var property mes = 0

  method transcurreUnMes(unaPersona) {
    unaPersona.cobrarSueldo()
    mes =+1 
    
  }
  
}

//Cree el efecitvo como una clase porque si lo creaba como objeto las personas al modificar el efectivo  estaria modificandolos todas el "mismo"
//efectivo y la idea de que cada uno tengo el suyo. Ahora no lo cree como una variable porque en la clase persona por que es polimorfico a las tarjetas

class Efectivo {
  var property dineroDisponible 
  var property debitoInstantaneo = true 
  var property efectivo = true
  

  method efectuarCompraPor(unValor) {
    dineroDisponible =- unValor
    
  }

  method recibirDineroPor(unValor) {
    dineroDisponible =+ unValor
    
  }

  method disminuirDineroPor(unValor) {
    dineroDisponible =- unValor
    
  }

}

class Debito {
  var property dineroDisponible 
  var property debitoInstantaneo = true 
  var property titualaresDeLaCuenta 
  var property efectivo = false


  method efectuarCompraPor(unValor) {
    dineroDisponible =- unValor
  }

  
}

class TarjetaCredito {
  var property dineroDisponible 
  var property cantidadCuotas 
  var property interesMensual 
  var property debitoInstantaneo = false 
  var property efectivo = false
  var property deudaTotalDeTarjeta  

  method deudaTotalPorMes() = deudaTotalDeTarjeta / cantidadCuotas 

  method efectuarCompraPor(unValor) {
    if(dineroDisponible > unValor){
    deudaTotalDeTarjeta =+ unValor * interesMensual
    dineroDisponible =- unValor}

    else throw new DomainException(message ="No hay limite suficiente")
  }
  method pagarDeudasDelMes() {
    deudaTotalDeTarjeta =- self.deudaTotalPorMes()
    
  }


  
}

class Trabajo{
  var property sueldoActual

  method aumentoDeSueldo(porcentaje) = 
  if(porcentaje > 1)
  sueldoActual =+ sueldoActual * porcentaje
  else 
    throw new DomainException(message = "El salario no puede disminuirse")

}

class Objeto{
  var property valor

}

class CompradoresCompulsivos inherits Persona{

  override method comprarUnObjeto(objeto) {
    super(objeto)
    metodosDePago.find({metodo => metodo.dineroDisponible() > objeto.valor()}).efectuarCompraPor(objeto.valor())
    
    
  }

}

class PagadoresCompulsivos inherits Persona{


  override method cobrarSueldo() {
    super()
    //variables locales para evitar tener que desarrollar toda esa logica y entorpecer el codigo
    const cantidadDeEfectivo =   metodosDePago.find({metodo => metodo.efectivo()}).dineroDisponible()
    const remanante = trabajo.sueldoActual() - self.totalDeudasDelMes()
    const diferencia = cantidadDeEfectivo - remanante

    if(diferencia > 0 ) //osea que lo puede pagar con efectivo
      self.tarjetasDeCreditos().forEach({tarjeta => tarjeta.pagarDeudaDelMes()})
      self.agregarEfectivo(-diferencia) //le sumo algo negativo para aprovechar el meotodo creado antes

    
    }
}
