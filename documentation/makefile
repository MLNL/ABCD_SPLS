PYTHON3 = python3
PYTHON2 = python2
MKDOCS = mkdocs
MFILES = ../plot/plot_paropt.md \
../plot/plot_proj.md \
../plot/plot_weight.md \
../cfg_defaults.md \
../res_defaults.md \
../demo/demo_simulation.md \
../demo/demo_smri.md \
../demo/demo_fmri.md \
../fileio/cleanup_files.md \
../set_path.md \
../util/update_dir.md

mfiledir = docs/mfiles

$(info mfiledir is $(mfiledir))


build-mfiles: $(MFILES)

%.md: %.m matdoc.py matdocparser.py
	$(info $(@))
	$(info $(@D))
	mkdir -p $(mfiledir)
	$(PYTHON2) ./matdoc.py "$(<)" > "$(mfiledir)/$(notdir $(@))"

serve: mkdocs.yml
	$(MKDOCS) serve

build: mkdocs.yml
	$(MKDOCS) build

clean:
	rm -f $(MFILES)
	rm -rf $(mfiledir)
