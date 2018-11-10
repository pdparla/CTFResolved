require 'ecdsa'

public_key_hex = '0233c34bc8d6faa151adc50734c6fb6ac7ff8cfa76d802872ca20676873b703e5a'
msghash1_hex = '71c34295405728ea65f8cab872348075b51593ab1630ff0d359fc17e68892cf2'
msghash2_hex = '8a3a8dfcd277beb4aa59ba5b936f3af38f08dc0392858cf475c51dc6247c3d90'
sig1_hex = '304402207d0543872fd6dda231d31b3d42a6717ed162a1a5124ef67cb9f843bb555ec6d60220648b78d767616c2c91e2bf75dbca6fdbeb8fb19ff53420fcac937c937ff291b0'
sig2_hex = '304402207d0543872fd6dda231d31b3d42a6717ed162a1a5124ef67cb9f843bb555ec6d602208e5685ba5e526f5923e2c07e9bf757b5ab2c6f9648f0f769a2669a1a34f8a243'
group = ECDSA::Group::Secp256k1

def hex_to_binary(str)
  str.scan(/../).map(&:hex).pack('C*')
end

public_key_str = hex_to_binary(public_key_hex)
public_key = ECDSA::Format::PointOctetString.decode(public_key_str, group)

#Coordenadas en la curva eliptica
puts 'public key x: %#x' % public_key.x
puts 'public key y: %#x' % public_key.y

#Parseamos para poder tratar con librería
msghash1 = hex_to_binary(msghash1_hex)
msghash2 = hex_to_binary(msghash2_hex)
sig1 = ECDSA::Format::SignatureDerString.decode(hex_to_binary(sig1_hex))
sig2 = ECDSA::Format::SignatureDerString.decode(hex_to_binary(sig2_hex))

raise 'R values are not the same' if sig1.r != sig2.r


r = sig1.r
puts 'sig r: %#x' % r
puts 'sig1 s: %#x' % sig1.s
puts 'sig2 s: %#x' % "0x8e5685ba5e526f5923e2c07e9bf757b5ab2c6f9648f0f769a2669a1a34f8a243"#sig.s fuck you

#Si no son validas no lo saco ni de coña asique sudo de validar
#sig1_valid = ECDSA.valid_signature?(public_key, msghash1, sig1)
#sig2_valid = ECDSA.valid_signature?(public_key, msghash2, sig2)
#puts "sig1 valid: #{sig1_valid}"
#puts "sig2 valid: #{sig2_valid}"

# Step 1: k = (z1 - z2)/(s1 - s2)
field = ECDSA::PrimeField.new(group.order)
z1 = ECDSA::Format::IntegerOctetString.decode(msghash1)
z2 = ECDSA::Format::IntegerOctetString.decode(msghash2)

k_candidates = [
  field.mod((z1 - z2) * field.inverse(sig1.s - Integer("0x8e5685ba5e526f5923e2c07e9bf757b5ab2c6f9648f0f769a2669a1a34f8a243"))),
  field.mod((z1 - z2) * field.inverse(sig1.s + Integer("0x8e5685ba5e526f5923e2c07e9bf757b5ab2c6f9648f0f769a2669a1a34f8a243"))),
  field.mod((z1 - z2) * field.inverse(-sig1.s - Integer("0x8e5685ba5e526f5923e2c07e9bf757b5ab2c6f9648f0f769a2669a1a34f8a243"))),
  field.mod((z1 - z2) * field.inverse(-sig1.s + Integer("0x8e5685ba5e526f5923e2c07e9bf757b5ab2c6f9648f0f769a2669a1a34f8a243"))),
]

#Devolvemos las claves candidatas a ser la nuestra
private_key = nil
k_candidates.each do |k|
  next unless group.new_point(k).x == r
  private_key_maybe = field.mod(field.mod(sig1.s * k - z1) * field.inverse(r))
  if public_key == group.new_point(private_key_maybe)
    private_key = private_key_maybe
  end
end

puts 'private key: %#x' % private_key
