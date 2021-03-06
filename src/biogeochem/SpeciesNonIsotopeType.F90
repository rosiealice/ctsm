module SpeciesNonIsotopeType

  !-----------------------------------------------------------------------
  ! !DESCRIPTION:
  ! Defines a class for working with chemical species, such as building history and
  ! restart field names.
  !
  ! This version is used for non-isotopic species
  !
  ! !USES:
  !
  use SpeciesBaseType, only : species_base_type
  use abortutils, only : endrun
  use shr_log_mod, only : errMsg => shr_log_errMsg
  use clm_varctl, only : iulog

  implicit none
  save
  private

  ! COMPILER_BUG(wjs, 2016-03-16, pgi 15.10) Ideally, we would use an allocatable
  ! character variable for species_name. However, this causes problems for pgi: it seems
  ! that this allocatable character variable randomly gets changed. So, for now, using a
  ! fixed-length character variable. (It's possible that this was programmer error on my
  ! part, although using allocatable character variables worked with other compilers.)
  !
  ! If species_name was changed back to an allocatable-length character variable, then we
  ! could remove the error checking in the constructor as well as various 'trim'
  ! statements scattered throughout the code (because this%species_name would already be
  ! trimmed).
  integer, parameter :: species_name_maxlen = 8

  type, extends(species_base_type), public :: species_non_isotope_type
     private
     character(len=species_name_maxlen) :: species_name
   contains
     procedure, public :: hist_fname
     procedure, public :: rest_fname
     procedure, public :: get_species
  end type species_non_isotope_type

  interface species_non_isotope_type
     module procedure constructor
  end interface species_non_isotope_type

  character(len=*), parameter, private :: sourcefile = &
       __FILE__

contains

  function constructor(species_name) result(this)
    ! Create a species_non_isotope_type object

    type(species_non_isotope_type) :: this  ! function result
    character(len=*), intent(in) :: species_name  ! e.g., 'C' or 'N'
    !-----------------------------------------------------------------------

    if (len_trim(species_name) > species_name_maxlen) then
       write(iulog,*) 'species_isotope_type constructor: species_name too long'
       write(iulog,*) trim(species_name) // ' exceeds max length: ', species_name_maxlen
       call endrun(msg='species_isotope_type constructor: species_name too long: '// &
            errMsg(sourcefile, __LINE__))
    end if

    this%species_name = trim(species_name)
  end function constructor

  pure function hist_fname(this, basename, suffix) result(fname)
    ! Get a history field name for this species
    !
    ! basename gives the base name of the history field
    !
    ! suffix, if provided, gives a suffix that appears after all species information
    ! in the field name

    character(len=:), allocatable :: fname  ! function result
    class(species_non_isotope_type) , intent(in)  :: this
    character(len=*), intent(in)  :: basename
    character(len=*), optional, intent(in) :: suffix
    !-----------------------------------------------------------------------

    fname = trim(basename) // trim(this%species_name)
    if (present(suffix)) then
       fname = trim(fname) // trim(suffix)
    end if

  end function hist_fname

  function rest_fname(this, basename, suffix) result(fname)
    ! Get a restart field name for this species
    !
    ! basename gives the base name of the restart field
    !
    ! suffix, if provided, gives a suffix that appears after all species information in
    ! the field name
    use shr_string_mod, only : shr_string_toLower

    character(len=:), allocatable :: fname  ! function result
    class(species_non_isotope_type) , intent(in)  :: this
    character(len=*), intent(in)  :: basename
    character(len=*), optional, intent(in) :: suffix

    character(len=:), allocatable :: species_name_lcase
    !-----------------------------------------------------------------------

    species_name_lcase = shr_string_toLower(trim(this%species_name))
    fname = trim(basename) // trim(species_name_lcase)
    if (present(suffix)) then
       fname = trim(fname) // trim(suffix)
    end if

  end function rest_fname

  pure function get_species(this) result(species_name)
    ! Get the full species name

    character(len=:), allocatable :: species_name
    class(species_non_isotope_type) , intent(in)  :: this
    !-----------------------------------------------------------------------

    species_name = trim(this%species_name)

  end function get_species

end module SpeciesNonIsotopeType
