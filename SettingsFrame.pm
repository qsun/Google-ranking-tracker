package SettingsFrame;

use MainFrame;
use KeywordStore;

use Wx qw[:everything];
use base qw(Wx::Frame);
use strict;

use Data::Dumper;

sub new {
	my( $self, $parent, $id, $title, $pos, $size, $style, $name ) = @_;

    my $dbh = KeywordStore::connect();

	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

	$style = wxDEFAULT_FRAME_STYLE 
		unless defined $style;

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{label_1} = Wx::StaticText->new($self, -1, "website: ", wxDefaultPosition, wxDefaultSize, );
	$self->{static_line_1} = Wx::StaticLine->new($self, -1, wxDefaultPosition, wxDefaultSize, wxLI_VERTICAL);
	$self->{domain_text_control} = Wx::TextCtrl->new($self, -1, KeywordStore::get_domain($dbh), wxDefaultPosition, wxDefaultSize, wxTE_CENTRE);
	$self->{confirm_button} = Wx::Button->new($self, -1, "Confirm");
	$self->{label_2} = Wx::StaticText->new($self, -1, "keywords settings: ", wxDefaultPosition, wxDefaultSize, );
	$self->{keyword_text_ctrl} = Wx::TextCtrl->new($self, -1, "Please input new keyword here", wxDefaultPosition, wxDefaultSize, );
	$self->{add_keyword_button} = Wx::Button->new($self, -1, "add this keyword");
	$self->{keyword_list_box} = Wx::ListBox->new($self, -1, wxDefaultPosition, wxDefaultSize, [], wxLB_MULTIPLE);
	$self->{delete_button} = Wx::Button->new($self, -1, "delete");

    $self->{keywords_ref} = KeywordStore::get_keywords($dbh);
    $self->reload_keywords;

    Wx::Event::EVT_CLOSE($self, \&settings_frame_onclose);

	$self->__set_properties();
	$self->__do_layout();

    Wx::Event::EVT_BUTTON($self, $self->{delete_button}->GetId, \&delete_button_clicked);
	Wx::Event::EVT_BUTTON($self, $self->{add_keyword_button}->GetId, \&add_keyword_clicked);
	Wx::Event::EVT_BUTTON($self, $self->{confirm_button}->GetId, \&save_domain_button_clicked);

# end wxGlade
	return $self;
}

sub delete_button_clicked {
    my ($self) = @_;

    my @new_keywords = @{$self->{keywords_ref}};

    my $dbh = KeywordStore::connect();

    foreach my $target_idx (sort {$b <=> $a} $self->{keyword_list_box}->GetSelections()) {
        print $target_idx, "\n";

        KeywordStore::del_keyword($dbh, $new_keywords[$target_idx]);
    }

    $self->{keywords_ref} = KeywordStore::get_keywords($dbh);
    $self->reload_keywords;
}

sub add_keyword_clicked {
    my ($self) = @_;
    my $new_keyword = $self->{keyword_text_ctrl}->GetValue();
    if ('' ne $new_keyword) {
        KeywordStore::add_keyword(KeywordStore::connect(), $new_keyword);
        my @new_keywords = @{$self->{keywords_ref}};
        push @new_keywords, $new_keyword;
        $self->{keywords_ref} = \@new_keywords;

        $self->reload_keywords;
    }
}

sub reload_keywords {
    my ($self) = @_;

    print Dumper($self->{keywords_ref});
    
    $self->{keyword_list_box}->Clear;

    $self->{keyword_list_box}->Set($self->{keywords_ref});
}

sub settings_frame_onclose {
    my ($self) = @_;

    $MainFrame::main_frame->reload_keywords;
    $MainFrame::main_frame->redraw_keywords;
    $MainFrame::main_frame->Show(1);
    $self->Destroy();
}

sub save_domain_button_clicked {
    my ($self) = @_;

    my $dbh = KeywordStore::connect();
    KeywordStore::set_domain($dbh, $self->{domain_text_control}->GetValue());
}

sub __set_properties {
	my $self = shift;


	$self->SetTitle("ParDiff Keyword Settings");
	$self->SetSize(Wx::Size->new(687, 395));

# end wxGlade
}

sub __do_layout {
	my $self = shift;

	$self->{sizer_1} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_4} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_5} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_6} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_7} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_2} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_3} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_2}->Add(20, 20, 0, 0, 0);
	$self->{sizer_2}->Add($self->{label_1}, 0, wxEXPAND, 0);
	$self->{sizer_2}->Add($self->{static_line_1}, 0, 0, 0);
	$self->{sizer_3}->Add($self->{domain_text_control}, 0, wxEXPAND, 0);
	$self->{sizer_2}->Add($self->{sizer_3}, 1, wxEXPAND, 0);
	$self->{sizer_2}->Add($self->{confirm_button}, 0, 0, 0);
	$self->{sizer_1}->Add($self->{sizer_2}, 0, wxEXPAND, 0);
	$self->{sizer_1}->Add(20, 20, 0, 0, 0);
	$self->{sizer_4}->Add(20, 20, 0, 0, 0);
	$self->{sizer_4}->Add($self->{label_2}, 0, 0, 0);
	$self->{sizer_7}->Add($self->{keyword_text_ctrl}, 0, wxEXPAND, 0);
	$self->{sizer_7}->Add(20, 20, 0, 0, 0);
	$self->{sizer_7}->Add($self->{add_keyword_button}, 0, 0, 0);
	$self->{sizer_4}->Add($self->{sizer_7}, 1, wxEXPAND, 0);
	$self->{sizer_4}->Add(20, 20, 0, 0, 0);
	$self->{sizer_5}->Add($self->{keyword_list_box}, 2, wxEXPAND, 0);
	$self->{sizer_6}->Add($self->{delete_button}, 0, 0, 0);
	$self->{sizer_5}->Add($self->{sizer_6}, 0, wxEXPAND, 0);
	$self->{sizer_4}->Add($self->{sizer_5}, 1, wxEXPAND, 0);
	$self->{sizer_1}->Add($self->{sizer_4}, 1, wxEXPAND, 0);
	$self->SetSizer($self->{sizer_1});
	$self->Layout();

# end wxGlade
}

1;

# package SettingsApp;

# use base qw(Wx::App);
# use strict;

# sub OnInit {
# 	my( $self ) = shift;

# 	Wx::InitAllImageHandlers();

# 	my $frame_1 = MyFrame->new();

# 	$self->SetTopWindow($frame_1);
# 	$frame_1->Show(1);

# 	return 1;
# }
# # end of class SettingsApp
