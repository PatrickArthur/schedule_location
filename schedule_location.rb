# class that takes a patient and appointment and matches a doctor by availibility and location
class FindDoctor
  def initialize(patient, appointment_time)
    @patient = patient
    @appointment_time = appointment_time
  end

  def start_doctor_search
    check_times(@patient.find_doctors)
  end

  private

  def check_times(doctors)
    hash = {}
    array = []
    find_doc_time(doctors, array, hash)
  end

  def find_doc_time(doctors, array, hash)
    doctors.each { |doc| check_avail_times(doc, hash, array) }
    remove_booked_dates(hash)
  end

  def check_avail_times(doc, hash, array)
    if !doc.available_times.nil?
      append_app_times(doc, array)
      hash[doc.id] = array
    else
      hash[doc.id] = doc.available_times
    end
  end

  def append_app_times(doc, array)
    doc.available_times.each { |t| array << t.appointment_time }
  end

  def remove_booked_dates(hash)
    hash.each do |_k, v|
      next unless v.present?
      v.each do |date|
        form = date.strftime('%m/%d/%Y')
        (form == @appointment_time) ? v.delete(@appointment_time) : v.delete(v.last)
      end
    end
    check_location(hash)
  end

  def check_location(hash)
    hash2 = {}
    hash.each do |k, _v|
      d = Doctor.find(k)
      check = Geocoder::Calculations.distance_between([d.latitude, d.longitude], [@patient.latitude, @patient.longitude])
      (check <= 10) ? hash2[k] = check : nil
    end
    make_appointment(hash2.min)
  end

  def make_appointment(arr)
    save_appointment(arr) unless arr.nil?
    !d.nil?
  end

  def save_appointment(arr)
    d = Doctor.find(arr.first)
    date = Date.strptime(@appointment_time, '%m/%d/%y')
    a = Appointment.new(patient_id: @patient.id, appointment_time: date)
    d.appointments << a
    send_mailer(d, date)
    d.save
  end

  def send_mailer(d, date)
    DoctorMailer.appointment_email(d, date, @patient).deliver_now
    PatientMailer.appointment_email(@patient, date, d).deliver_now
  end
end
