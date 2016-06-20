# class that takes a patient and appointment and matches a doctor by availibility and location
class FindDoctor
  def initialize(patient, appointment_time)
    @patient = patient
    @appointment_time = appointment_time
  end

  def start_doctor_search
    check_location(@patient.find_doctors) ? true : 'No Doctors'
  end

  private

  def check_location(doctors)
    local_docs = []
    calc_distance(doctors)
    find_availible(local_docs)
  end

  def calc_distance(doctors)
    doctors.each do |doc|
      check = Geocoder::Calculations.distance_between([doc.latitude, doc.longitude],
                                                      [@patient.latitude, @patient.longitude])
      (check <= 10) ? local_docs << doc : nil
    end
  end

  def find_availible(doctors)
    avail_doc = []
    doctors.each { |doc| doc.avail(@appointment_time) ? avail_doc << doc : nil }
    make_appointment(avail_doc)
  end

  def make_appointment(doctors)
    !doctors.empty? ? save_appointment(doctors) : false
  end

  def save_appointment(doctors)
    doctor = doctors.sample
    date = Date.strptime(@appointment_time, '%m/%d/%y')
    doctor.appointments << Appointment.new(patient_id: @patient.id, appointment_time: date)
    send_mailer(doctor, date)
    doctor.save
  end

  def send_mailer(doctor, date)
    DoctorMailer.appointment_email(doctor, date, @patient).deliver_now
    PatientMailer.appointment_email(@patient, date, doctor).deliver_now
  end
end
