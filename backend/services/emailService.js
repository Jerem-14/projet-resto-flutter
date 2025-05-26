const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API);

const sendWelcomeEmail = async (userEmail, firstName, lastName) => {
  try {
    const { data, error } = await resend.emails.send({
      from: process.env.FROM_EMAIL || 'Restaurant App <onboarding@resend.dev>',
      to: [userEmail],
      subject: 'Bienvenue dans notre application restaurant !',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <h1 style="color: #333; text-align: center;">Bienvenue ${firstName} ${lastName} !</h1>
          
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h2 style="color: #28a745; margin-top: 0;">Votre compte a été créé avec succès !</h2>
            <p style="color: #666; line-height: 1.6;">
              Nous sommes ravis de vous accueillir dans notre application de restaurant. 
              Vous pouvez maintenant explorer nos menus, passer des commandes et profiter 
              de nos services.
            </p>
          </div>
          
          <div style="margin: 30px 0;">
            <h3 style="color: #333;">Que pouvez-vous faire maintenant ?</h3>
            <ul style="color: #666; line-height: 1.8;">
              <li>📱 Explorer notre menu complet</li>
              <li>🍽️ Passer votre première commande</li>
              <li>⭐ Découvrir nos plats populaires</li>
              <li>📍 Trouver nos restaurants près de chez vous</li>
            </ul>
          </div>
          
          <div style="text-align: center; margin: 30px 0;">
            <p style="color: #666;">
              Si vous avez des questions, n'hésitez pas à nous contacter.
            </p>
            <p style="color: #666; font-size: 14px;">
              Merci de nous faire confiance !<br>
              L'équipe Restaurant App
            </p>
          </div>
          
          <div style="border-top: 1px solid #eee; padding-top: 20px; text-align: center; font-size: 12px; color: #999;">
            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
          </div>
        </div>
      `,
    });

    if (error) {
      console.error('Erreur lors de l\'envoi de l\'email de bienvenue:', error);
      return { success: false, error };
    }

    console.log('Email de bienvenue envoyé avec succès:', data);
    return { success: true, data };
  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email de bienvenue:', error);
    return { success: false, error: error.message };
  }
};

module.exports = {
  sendWelcomeEmail
}; 