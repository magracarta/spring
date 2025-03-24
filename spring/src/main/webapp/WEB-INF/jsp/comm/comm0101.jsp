<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp" /><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt"%><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%><%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 조직관리 > null > null
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp" />
<script type="text/javascript">

	var auiGrid;
	var auiGridMonitor;
	var auiGridAgency;
	var monitorOrgCode = "";
	var dataFieldName = []; // 펼침 항목(create할때 넣음)

	var btnAccessArray = [{code_value : "H", code_name : "상"}, {code_value : "M", code_name : "중"}, {code_value : "B", code_name : "하"}];

	$(document).ready(function() {
		createAUIGrid();
		createAUIGridMonitor();
		createAUIGridAgency();
		goSearch();
	});

	// 파일첨부팝업
	function goFileUploadPopup() {
		var param = {
			upload_type : 'COMM',
			file_type : 'both',
			file_ext_type : 'pdf#img',
			max_size : 5000
		}
		openFileUploadPanel('fnSetFile', $M.toGetParam(param));
	}

	function fnSetFile(file) {
		fnPrintFile(file.file_seq, file.file_name);
	}

	// 파일세팅
	function fnPrintFile(fileSeq, fileName) {
		var str = '';
		str += '<div class="table-attfile-item submit">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" name="contract_file_seq" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFile()"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.submit_div').append(str);
		$("#btn_submit").remove();
	}

	// 첨부파일 삭제
	function fnRemoveFile() {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".submit").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit">파일찾기</button>'
			$('.submit_div').append(str);
		} else {
			return false;
		}
	}

	// 첨부파일 리셋
	function fnResetFile() {
		// 계약서 파일 리셋
		$(".submit").remove();
		$("#btn_submit").remove();
		var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit">파일찾기</button>'
		$('.submit_div').append(str);

		// 센터 대표 이미지 리셋
		$(".submit_rep").remove();
		$("#btn_submit_rep_file").remove();
		var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goRepFileUploadPopup()" id="btn_submit_rep_file">파일찾기</button>'
		$('.submit_div_rep').append(str);
	}

	// 상위조직 변경 이벤트
	function fnChangeOrgCode(data) {
		if($M.getValue('cmd') != 'C') {
			return;
		}

		var orgCode = Math.floor(data.value / 100); // 앞 두자리만 필요
		var agencyUpOrgCodeList = ${agencyUpOrgCodeList}; // 대리점 코드 리스트

		// 건기, 농기, 특수 대리점의 경우 자동 조직코드
// 		if(agencyUpOrgCodeList.includes(orgCode)) { // 클릭된 상위조직이 대리점 리스트에 있을 경우
		if("Y" == data.options[data.selectedIndex].getAttribute("auto_new_org_yn")) {
			$M.goNextPageAjax(this_page + '/maxorg/' + orgCode, "", {method : 'get'}, function(result) {
				if (result.success) {
					$M.setValue("org_code", result.maxOrgCode); // 값 변경
					$M.setValue("sort_no", result.maxSortNo); // 값 변경
					$("#org_code").attr("readonly", true); // 수정 불가
					console.log("result : ", result);
				}
			});
		} else {
			$("#org_code").attr("readonly", false); // 수정 가능
			$("#org_code").val(""); // 값 초기화
		}
	}

	function fnSetAgencyMaster(row) {
		$M.setValue("cust_no", row.cust_no);
		$M.setValue("cust_name", row.real_cust_name);
		$M.setValue("sale_ability_hmb", row.sale_ability_hmb);
		if(row.sale_contract_dt != '') {
			$M.setValue("sale_contract_dt", row.sale_contract_dt);
		}
		if(row.sale_contract_ed_dt != '') {
			$M.setValue("sale_contract_ed_dt", row.sale_contract_ed_dt);
		}
	}

	function goCustDetail() {
		var custNo = $M.getValue("cust_no");
		if (custNo == "") {
			return false;
		}
		var param = {
			cust_no : custNo
		}
		var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
		$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
	}

	function goSearch() {
		var param = {
			"s_include_menu_org_yn" : "N", //$M.getValue("s_include_menu_org_yn"),
			"s_sort_key" : "org_code",
			"s_sort_method" : "asc",
		};
		$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'}, function(result) {
			if (result.success) {
				var frm = document.main_form;
				AUIGrid.setGridData(auiGrid, result.list);
				AUIGrid.expandAll(auiGrid);
			}
		});
		fnChangeImprest();
	}

	function fnChangeForm(param) {
		if (param == 'CENTER') {
			$('.section-inner').removeClass('active');
			$('.section-inner-franc').removeClass('active');
			$('.section-inner-center').addClass('active');
		} else if (param == 'AGENCY') {
			$('.section-inner').removeClass('active');
			$('.section-inner-center').removeClass('active');
			$('.section-inner-franc').addClass('active');
		} else {
			$('.section-inner-center').removeClass('active');
			$('.section-inner-franc').removeClass('active');
			$('.section-inner').addClass('active');
		}

		if (param == 'AGENCY') {
			$M.setValue("imprest_mng_yn", "N");
		}
	}

	// 왼쪽 조직목록 그리드
	function createAUIGrid() {
		var gridPros = {
			rowIdField : "org_code",
			height : 555,
			displayTreeOpen : false,
			rowCheckDependingTree : true,
			showRowNumColumn : false,
			enableFilter : true,
			treeColumnIndex : 1,
		};
		var columnLayout = [
		{
			headerText : "조직",
			dataField : "org_code",
			width : "60",
			minWidth : "60",
			style : "aui-center",
			editable : false,
			filter : {
				showIcon : true
			}
		},
		{
			headerText : "조직명",
			dataField : "org_name",
			style : "aui-left aui-link",
			editable : false,
			filter : {
				showIcon : true
			},
		},
		{
			headerText : "구분",
			dataField : "org_gubun_name",
			width : "50",
			minWidth : "50",
			style : "aui-center",
			editable : false,
			filter : {
				showIcon : true
			}
		},
		{
			// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
			// headerText : "대리점주명",
			headerText : "위탁판매점주명",
			dataField : "cust_name",
			width : "70",
			minWidth : "70",
			style : "aui-center",
			editable : false,
			filter : {
				showIcon : true
			}
		},
		{
			headerText : "계약일자",
			headerStyle : "aui-fold",
			dataField : "",
			width : "140",
			minWidth : "140",
			style : "aui-center",
			editable : false,
			labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
				var saleContractDt = item.sale_contract_dt;
				var saleContractEdDt = item.sale_contract_ed_dt;

				if (saleContractEdDt != "") {
					return saleContractDt + " ~ " + saleContractEdDt;
				} else if(saleContractDt != "") {
					return saleContractDt + " ~ ";
				} else {
					return "";
				}
			}
		},
		{
			headerText : "사용",
			dataField : "use_yn",
			width : "50",
			minWidth : "50",
			style : "aui-center",
			editable : false,
			filter : {
				showIcon : true
			}
		},
		{
			headerText : "거래정지",
			dataField : "stop_yn",
			width : "70",
			minWidth : "70",
			style : "aui-center",
			editable : false,
			filter : {
				showIcon : true
			}
		},
		{
			headerText : "더존코드",
			dataField : "duzon_org_code",
			width : "70",
			minWidth : "70",
			style : "aui-center",
			editable : false,
			filter : {
				showIcon : true
			}
		},
		{
			dataField : "depth_2",
			visible : false
		}
		];

		auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
		AUIGrid.setGridData(auiGrid, []);

		// 펼치기 전에 접힐 컬럼 목록
		var auiColList = AUIGrid.getColumnInfoList(auiGrid);
		for (var i = 0; i <auiColList.length; ++i) {
			if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
				dataFieldName.push(auiColList[i].dataField);
			}
		}

		for (var i = 0; i < dataFieldName.length; ++i) {
			var dataField = dataFieldName[i];
			AUIGrid.hideColumnByDataField(auiGrid, dataField);
		}

		$("#auiGrid").resize();
		AUIGrid.bind(auiGrid, "cellClick", function(event) {
			if (event.dataField != "org_name" || event.treeIcon == true) {
				return false;
			}
			var param = {
				"org_code" : event.item["org_code"]
			};
			monitorOrgCode = event.item["org_code"];

			if (event.item.depth_2 == "M000") {
				// 모니터딜러 조회면 모니터 딜러 목록조회
				$("#monitor").removeClass("dpn");
				$("#agencylist").addClass("dpn");
				$("#normal").addClass("dpn");
				goSearchMonitorSubList();
			} else if (event.item.org_code == "A000") {
				// 대리점 조회
				$("#agencylist").removeClass("dpn");
				$("#monitor").addClass("dpn");
				$("#normal").addClass("dpn");
				goSearchAgencyList();
			} else {
				// 모니터딜러 조회가 아니면 일반 조직 상세 조회
				$("#normal").removeClass("dpn");
				$("#agencylist").addClass("dpn");
				$("#monitor").addClass("dpn");
				goSearchDetail(param);
			}
		});
	}

	// 모니터 서브딜러 그리드
	function createAUIGridMonitor() {
		var gridPros = {
			rowIdField : "cust_no",
			height : 555,
			showRowNumColumn : true,
			enableFilter : true,
			editable : true
		};
		var columnLayout = [
			{
				dataField : "cust_no",
				visible : false
			},
			{
				headerText : "구분",
				dataField : "cust_sale_type_name",
				width : "50",
				minWidth : "50",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "센터",
				dataField : "center_org_name",
				width : "60",
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "권역",
				dataField : "area_do",
				width : "60",
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "시/군",
				dataField : "area_si",
				width : "60",
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "고객명",
				dataField : "cust_name",
				width : "90",
				minWidth : "60",
				style : "aui-center aui-link",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "위탁판매점계약일자",
				dataField : "sale_contract_dt",
				dataType : "date",
				width : "90",
				minWidth : "90",
				style : "aui-center aui-editable",
				dataInputString : "yyyymmdd",
				formatString : "yy-mm-dd",
				editRenderer : {
					type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
					defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
					onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
					maxlength : 8,
					onlyNumeric : true, // 숫자만
					validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
						return fnCheckDate(oldValue, newValue, rowItem);
					},
					showEditorBtnOver : true
				},
				editable : true
			},
			{
				headerText : "마케팅능력",
				dataField : "sale_ability_hmb",
				width : "70",
				minWidth : "70",
				style : "aui-center aui-editable",
				editRenderer : {
					showEditorBtnOver : true, // 마우스 오버 시 에디터버턴 보이기
					type : "DropDownListRenderer",
					keyField : 'code_value',
					valueField : 'code_name',
					list : btnAccessArray,
					showEditorBtnOver : true,
					required : true
				},
				labelFunction : function(rowIndex, columnIndex, value){
					for(var i=0; i<btnAccessArray.length; i++){
						if(value == btnAccessArray[i].code_value){
							return btnAccessArray[i].code_name;
						}
					}
					return value;
				}
			},
			{
				headerText : "상호",
				dataField : "breg_name",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "대표",
				dataField : "breg_rep_name",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "휴대폰",
				dataField : "hp_no",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "사무실",
				dataField : "tel_no",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
			},
			{
				headerText : "주소",
				dataField : "full_addr",
				width : "180",
				minWidth : "100",
				style : "aui-left",
				editable : false,
			},
		];

		auiGridMonitor = AUIGrid.create("#auiGridMonitor", columnLayout, gridPros);
		AUIGrid.bind(auiGridMonitor, "cellClick", function(event) {
			if(event.dataField == 'cust_name'){
				var param = {
					cust_no : event.item["cust_no"],
					s_monitor_yn : "Y"
				};
				var poppupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=750, left=0, top=0";
				$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
			}
		});
		AUIGrid.setGridData(auiGridMonitor, []);
	}

	// 모니터/서브딜러 목록조회
	function goSearchMonitorSubList() {
		var param = {
			s_org_code : monitorOrgCode,
			s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
		}
		$("#auiGridMonitor").resize();
		$M.goNextPageAjax(this_page + "/monitor/search", $M.toGetParam(param), {method : 'get'},
			function(result) {
				if (result.success) {
					AUIGrid.setGridData(auiGridMonitor, result.list);
				}
			});
	}

	// 모니터 서브딜러 그리드
	function createAUIGridAgency() {
		var gridPros = {
			rowIdField : "cust_no",
			height : 555,
			showRowNumColumn : true,
			enableFilter : true,
			editable : true
		};
		var columnLayout = [
			{
				dataField : "cust_no",
				visible : false
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText : "대리점구분",
				headerText : "위탁판매점구분",
				dataField : "agency_gubun_name",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "마케팅구분",
				dataField : "agency_sale_type_name",
				width : "120",
				minWidth : "120",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText : "대리점명",
				headerText : "위탁판매점명",
				dataField : "org_kor_name",
				width : "100",
				minWidth : "100",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "거래정지여부",
				dataField : "stop_yn",
				width : "60",
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
				// headerText : "대리점주명",
				headerText : "위탁판매점주명",
				dataField : "cust_name",
				width : "100",
				minWidth : "60",
				style : "aui-center",
				editable : false,
				filter : {
					showIcon : true
				}
			},
			{
				headerText : "계약일자",
				dataField : "",
				width : "140",
				minWidth : "140",
				style : "aui-center",
				editable : false,
				labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
					var saleContractDt = item.sale_contract_dt;
					var saleContractEdDt = item.sale_contract_ed_dt;

					if (saleContractEdDt != "") {
						return saleContractDt + " ~ " + saleContractEdDt;
					} else if(saleContractDt != "") {
						return saleContractDt + " ~ ";
					} else {
						return "";
					}
				}
			},
		];

		auiGridAgency = AUIGrid.create("#auiGridAgency", columnLayout, gridPros);

		AUIGrid.setGridData(auiGridAgency, []);
	}

	// 모니터/서브딜러 목록조회
	function goSearchAgencyList() {
		var param = {
			s_masking_yn : $M.getValue("s_a_masking_yn") == "Y" ? "Y" : "N",
		}
		$("#auiGridAgency").resize();
		$M.goNextPageAjax(this_page + "/agency/search", $M.toGetParam(param), {method : 'get'},
		function(result) {
			if (result.success) {
				AUIGrid.setGridData(auiGridAgency, result.list);
			}
		});
	}

	// 모니터/서브 딜러 정보 저장
	function goSaveMonitor() {
		var custNoArr = [];
		var saleAbilityHmbArr = [];
		var saleContractDtArr = [];
		var editRows = AUIGrid.getEditedRowItems(auiGridMonitor);
		for (var i = 0; i < editRows.length; i++) {
			var custNo = editRows[i].cust_no;
			var hmb = editRows[i].sale_ability_hmb;
			var dt = editRows[i].sale_contract_dt;
			if (hmb == null || hmb == "") {
				var rowIndex = AUIGrid.getRowIndexesByValue(auiGridMonitor, "cust_no", custNo)[0];
				alert(rowIndex+1+"행에 마케팅능력이 없습니다.");
				return false;
			}
			if (dt == null || dt == "") {
				var rowIndex = AUIGrid.getRowIndexesByValue(auiGridMonitor, "cust_no", custNo)[0];
				alert(rowIndex+1+"행에 위탁판매점계약일자가 없습니다.");
				return false;
			}
			custNoArr.push(custNo);
			saleAbilityHmbArr.push(hmb);
			saleContractDtArr.push(dt);
		}

		var param = {
			cust_no_str : $M.getArrStr(custNoArr),
			sale_ability_hmb_str : $M.getArrStr(saleAbilityHmbArr),
			sale_contract_dt_str : $M.getArrStr(saleContractDtArr),
		}

		$M.goNextPageAjax(this_page + "/monitor", $M.toGetParam(param), {method : 'post'},
				function(result) {
					if (result.success) {
						AUIGrid.resetUpdatedItems(auiGridMonitor);
					}
				});
	}

	//그리드셀 클릭시
	function goSearchDetail(param) {
		fnNew();
		//param값 없으면 return
		if (param == null) {
			return;
		}
		$M.goNextPageAjax(this_page + "/" + param.org_code, '', {method : 'get'},
				function(result) {
					if (result.success) {
						// 파일 셋팅 초기화
						fnResetFile();
						
						var frm = document.main_form;
						$M.setValue(frm, "cmd", "U");
						$("#org_code").attr("readonly", true);
						//페이지 정보 TABLE FORM의 각각seletion에 데이터 값 입력
						var orgBean = result.orgBean;
						// 기본 정보
						$M.setValue(orgBean);

						// 조직 대표이미지 셋팅
						if(orgBean.img_file_seq != 0) {
							var centerFileObj = {
								file_seq: orgBean.img_file_seq,
								file_name: orgBean.img_file_name
							}
							fnSetFileRep(centerFileObj);
						}
						
						if (orgBean.org_gubun_cd == 'CENTER') {
							var centerBean = result.centerBean;
							// 센터 정보
							$M.setValue(centerBean);
							$M.setValue("center_rental_treat_yn", centerBean.rental_treat_yn);
							$M.setValue("center_warehouse_yn", centerBean.warehouse_yn);
							$M.setValue("center_machine_used_yn", centerBean.machine_used_yn);
							$M.setValue("net_show_yn", centerBean.net_show_yn);
							$M.setValue("net_name_pos_lr", centerBean.net_name_pos_lr);
						}
						if (orgBean.org_gubun_cd == 'AGENCY') {
							var agencyBean = result.agencyBean;
							// 대리점 정보
							$M.setValue(agencyBean);
							$M.setValue("agency_rental_treat_yn", agencyBean.rental_treat_yn);
							$M.setValue("agency_warehouse_yn", agencyBean.warehouse_yn);
							$M.setValue("agency_machine_used_yn", agencyBean.machine_used_yn);
							$M.setValue("sale_contract_dt", agencyBean.sale_contract_dt);
							$M.setValue("sale_contract_ed_dt", agencyBean.sale_contract_ed_dt);
							$M.setValue("sale_ability_hmb", agencyBean.sale_ability_hmb);
							if(agencyBean.contract_file_seq != 0) {
								agencyBean.file_seq = agencyBean.contract_file_seq;
								fnSetFile(agencyBean);
							}
						}
						if (orgBean.org_gubun_cd == "AGENCY") {
							fnChangeForm('AGENCY');
							$('#AGENCY').prop('checked', true);
						} else if (orgBean.org_gubun_cd == "CENTER") {
							fnChangeForm('CENTER');
							$('#CENTER').prop('checked', true);
						} else if (orgBean.org_gubun_cd == "BASE") {
							fnChangeForm('BASE');
							$('#BASE').prop('checked', true);
						}
						fnChangeImprest();
					}
				});
	}

	// 신규
	function fnNew() {
		var frm = document.main_form;
		$M.setValue(frm, "cmd", "C");
		$("#org_code").removeAttr("readonly");
		$(".org_gubun_cd").prop("checked", false);
		var setParam = {
			'org_code' : '',
			'org_kor_name' : '',
			'org_eng_name' : '',
			'up_org_code' : '',
			'sort_no' : '',
			'tree_show_yn' : 'Y',
			'use_yn' : 'Y',
			'tel_no' : '',
			'fax_no' : '',
			'post_no' : '',
			'addr1' : '',
			'addr2' : '',
			'org_mem_no' : '',
			'org_mem_name' : '',
			'part_warehouse_yn' : 'N',
			'menu_grade_cd' : '',

			'imprest_mng_yn' : 'N',
			'imprest_bank_code' : '',
			'imprest_mem_name' : '',

			'bank_code' : '',
			'imprest_mem_no' : '',
			'imprest_mem_name' : '',
			'part_tel_no' : '',
			'service_tel_no' : '',
			'sale_mem_no' : '',
			'sale_mem_name' : '',
			'center_rental_treat_yn' : 'N',
			'nigth_duty_yn' : 'N',
			'center_warehouse_yn' : 'N',
			'machine_in_yn' : 'N',
			'homi_mng_yn' : 'N',
			'dem_fore_yn' : 'N',
			'center_machine_used_yn' : 'N',

			'agency_rental_treat_yn' : 'N',
			'bjng_amt' : '',
			'dambo_amt' : '',
			'service_amt' : '',
			'delay_amt' : '',
			'max_amt' : '',
			'agency_warehouse_yn' : 'N',
			'stock_sum_yn' : 'N',
			'mon_accounts_hold_yn' : 'N',
			'stop_yn' : 'N',
			'agency_machine_used_yn' : 'N',
			'menu_org_yn' : 'N',

			'contract_file_seq' : '',
			'sale_contract_dt' : '',
			'sale_contract_ed_dt' : '',
			'sale_ability_hmb' : '',

			'addr_lat' : '',
			'addr_lng' : '',

			'duzon_org_code' : '',

			'cust_no' : '',
			'cust_name' : '',

			'machine_out_yn' : 'N',

			// 2024-05-09 황빛찬 (Q&A:22671) : 조직 저장시 오류 수정
			// 'reg_date' : null,
			// 'reg_id' : null,
			// 'upt_date' : null,
			// 'upt_id' : null,
			// 'del_date' : null,
			// 'del_id' : null,

			'img_file_seq' : '',
			'net_show_yn' : 'N',
			'net_map_org_name' : '',
			'net_dtl_org_name' : '',
			'net_pos_x' : '0',
			'net_pos_y' : '0',
			'net_name_pos_lr' : 'R',
		};
		$M.setValue(setParam);
		fnResetFile();
		$(".agency_gubun_cd").prop("checked", false);
		$(".agency_sale_type_cd").prop("checked", false);
		AUIGrid.clearSelection(auiGrid);
		fnChangeForm('BASE');
	}

	function fnChangeImprest() {
		if ($M.getValue("imprest_mng_yn") == "N") {
			$("#imprest_mem_btn").prop("disabled", true);
			$("#imprest_mem_no").attr("readonly", true);
			$("#imprest_bank_code").attr("readonly", true);
		} else {
			$("#imprest_mem_btn").prop("disabled", false);
			$("#imprest_mem_no").attr("readonly", false);
			$("#imprest_bank_code").attr("readonly", false);
		}
	}

	function goSave() {
		var frm = document.main_form;
		var params = AUIGrid.getGridData(auiGrid);
		var orgCode = [];
		if ($M.validation(frm) == false) {
			return;
		};
		// validation check
		if ($M.validation(document.main_form, {field : [ "tree_show_yn", "use_yn", "part_warehouse_yn" ]}) == false) {
			return;
		};
		if ($M.getValue("org_gubun_cd") == "CENTER") {
			// back_code 어디에서도 쓰는곳이 없어 validation 리스트에서 삭제
			if ($M.validation(document.main_form,
					{field : [ "center_rental_treat_yn",
						"nigth_duty_yn", "center_warehouse_yn",
						"machine_in_yn", "homi_mng_yn", "dem_fore_yn",
						"center_machine_used_yn" ]}) == false) {
				return;
			};
		} else if ($M.getValue("org_gubun_cd") == "AGENCY") {
			if ($M.validation(document.main_form, {
				field : [ "agency_gubun_cd", "agency_sale_type_cd",
						"agency_rental_treat_yn", "agency_warehouse_yn",
						"stock_sum_yn", "cust_name"]}) == false) {
				return;
			};

			if(!checkContractDate(true)) {
				return;
			}
		}
		for (var i = 0; i < params.length; i++) {
			orgCode.push(params[i].org_code);
		}
		if ($M.getValue(frm, "cmd") == "C") {
			$M.setValue("save_yn", "SAVE");
		} else {
			$M.setValue("save_yn", "MODIFY");
		}

		$M.goNextPageAjaxSave(this_page + '/save', $M.toValueForm(frm), {method : 'POST'},
			function(result) {
				if (result.success) {
					$M.setValue(frm, "cmd", "U");
					goSearch();
				}
			}
		);
	}

	// 부서장 팝업 직원조회 결과
	function fnSetOrgInfo(data) {
		$M.setValue("org_mem_no", data.mem_no);
		$M.setValue("org_mem_name", data.mem_name);
	}

	// 영업 팝업 직원조회 결과
	function fnSetSaleInfo(data) {
		$M.setValue("sale_mem_no", data.mem_no);
		$M.setValue("sale_mem_name", data.mem_name);
	}

	// 전도금 담당자 팝업 직원조회 결과
	function fnSetImprestInfo(data) {
		$M.setValue("imprest_mem_no", data.mem_no);
		$M.setValue("imprest_mem_name", data.mem_name);
	}

	// 주소팝업
	function fnJusoBiz(data) {
		var param = {
			addr : 	data.roadAddrPart1
		}

		$M.goNextPageAjax("/naverCloud/coordinate", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if (result.success) {
						$M.setValue("addr_lng", result.addr_lng);
						$M.setValue("addr_lat", result.addr_lat);
					}
					$M.setValue("post_no", data.zipNo);
					$M.setValue("addr1", data.roadAddrPart1);
					$M.setValue("addr2", data.addrDetail);
				});
	}

	function fnCalc() {
		var bjngAmt = $M.toNum($M.getValue("bjng_amt"));
		var delayAmt = $M.toNum($M.getValue("delay_amt"));
		var damboAmt = $M.toNum($M.getValue("dambo_amt"));

		var calcAmt = $M.toNum((bjngAmt + delayAmt + damboAmt) * 1.5);

		$M.setValue("max_amt", calcAmt)
	}

	function fnSetDefaultContractDate() {
		var saleContractDt = $M.getValue("sale_contract_dt");
		var defaultContractEdDt = $M.dateFormat($M.addDates($M.toDate(saleContractDt), 364),'yyyyMMdd');
		$M.setValue("sale_contract_ed_dt", defaultContractEdDt);
		checkContractDate(false);
	}

	function checkContractDate(confirmYn) {
		var check = $M.checkRangeByFieldName("sale_contract_dt", "sale_contract_ed_dt", "위탁판매점계약 종료일자를 시작일자 이후로 선택해주세요.");
		if(!check) {
			return check;
		}

		// 남은 위탁판매점 계약기간이 한달 미만일 경우 알림을 주기 위해 현재에서 한달 플러스
		var now = $M.dateFormat($M.addMonths($M.toDate($M.getCurrentDate('yyyyMMdd')), 1), 'yyyyMMdd');
		var contractEdDt = $M.getValue("sale_contract_ed_dt");

		if(contractEdDt < now && $M.getValue("stop_yn") == "N" && contractEdDt != "") {
			if(confirmYn) {
				return confirm("위탁판매점계약 종료기한이 한달 미만으로 남아있습니다.\n계속 진행하시겠습니까?");
			} else {
				alert("위탁판매점계약 종료기한이 한달 미만으로 남아있습니다.\n확인 후 처리해주세요.");
				return false;
			}
		}

		return true;
	}

	function fnChangeStopYn(stopYn) {
		if(stopYn == "N") {
			checkContractDate(false);
		}
	}

	function fnDownloadExcel() {
		  // 엑셀 내보내기 속성
		  var exportProps = {
		  };
		  fnExportExcel(auiGridMonitor, "조직정보", exportProps);
	}

	// 펼침
	function fnChangeColumn(event) {
		var data = AUIGrid.getGridData(auiGrid);
		var target = event.target || event.srcElement;
		if(!target)	return;

		var dataField = target.value;
		var checked = target.checked;

		for (var i = 0; i < dataFieldName.length; ++i) {
			var dataField = dataFieldName[i];

			if(checked) {
				AUIGrid.showColumnByDataField(auiGrid, dataField);
			} else {
				AUIGrid.hideColumnByDataField(auiGrid, dataField);
			}
		}

		// 구해진 칼럼 사이즈를 적용 시킴.
		/* var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
        AUIGrid.setColumnSizeList(auiGrid, colSizeList); */
	}

	// 대표이미지 파일첨부팝업
	function goRepFileUploadPopup() {
		var param = {
			upload_type : 'CENTER',
			file_type : 'img',
			max_width : 550,
			max_height : 330,
		}
		openFileUploadPanel('fnSetFileRep', $M.toGetParam(param));
	}

	function fnSetFileRep(file) {
		fnPrintFileRep(file.file_seq, file.file_name);
	}

	// 대표이미지 파일세팅
	function fnPrintFileRep(fileSeq, fileName) {
		var str = '';
		str += '<div class="table-attfile-item submit_rep">';
		str += '<a href="javascript:fileDownload(' + fileSeq + ');">' + fileName + '</a>&nbsp;';
		str += '<input type="hidden" name="img_file_seq" value="' + fileSeq + '"/>';
		str += '<button type="button" class="btn-default check-dis" onclick="javascript:fnRemoveFileRep()"><i class="material-iconsclose font-18 text-default"></i></button>';
		str += '</div>';
		$('.submit_div_rep').append(str);
		$("#btn_submit_rep_file").remove();
	}

	// 대표이미지 첨부파일 삭제
	function fnRemoveFileRep() {
		var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
		if (result) {
			$(".submit_rep").remove();
			var str = '<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goRepFileUploadPopup()" id="btn_submit_rep_file">파일찾기</button>'
			$('.submit_div_rep').append(str);
			$M.setValue("img_file_seq", "0");
		} else {
			return false;
		}
	}
	
	function goPreview() {
		var param = {
			left: $M.getValue('net_pos_x'),
			top: $M.getValue('net_pos_y'),
			// pos_lr: $M.getValue('pos_lr'),
			pos_lr: $M.getValue('net_name_pos_lr'), // 24.03.12 수정
			org_name: $M.getValue('net_map_org_name'),
		};
		var popupOption = "";
		$M.goNextPage('/comm/comm0101p01', $M.toGetParam(param), {popupStatus : popupOption});
	}

</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<input type="hidden" name="rental_treat_yn" id="rental_treat_yn"
			value=""> <input type="hidden" name="machine_used_yn"
			id="machine_used_yn" value=""> <input type="hidden"
			name="warehouse_yn" id="warehouse_yn" value="">
		<div class="layout-box">
			<!-- contents 전체 영역 -->
			<input type="hidden" id="cmd" name="cmd" value="C">
			<div class="content-wrap">
				<div class="content-box">
					<!-- 메인 타이틀 -->
					<div class="main-title">
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp" />
					</div>
					<!-- /메인 타이틀 -->
					<div class="contents">
						<div class="row">
							<!-- 메뉴목록 -->
							<div class="col-5">
								<div class="title-wrap mt10">
									<h4>조직목록</h4>
									<div class="btn-group">
										<div class="right">
											<div style="display: inline-block;">
												<label for="s_toggle_column" style="color:black;">
													<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
												</label>
<%--												<input type="checkbox" id="s_include_menu_org_yn" name="s_include_menu_org_yn" value="Y" onclick="javascript:goSearch()">--%>
<%--												<label for="s_include_menu_org_yn">부서권한 포함</label>--%>
											</div>
											<button type="button" onclick=AUIGrid.expandAll(auiGrid);
												class="btn btn-default">
												<i class="material-iconsadd text-default"></i>전체펼치기
											</button>
											<button type="button" onclick=AUIGrid.collapseAll(auiGrid);
												class="btn btn-default">
												<i class="material-iconsremove text-default"></i>전체접기
											</button>
											<button type="button" onclick="fnExportExcel(auiGrid, '조직목록', {});"
													class="btn btn-default">
												<i class="icon-btn-excel inline-btn"></i>엑셀다운로드
											</button>
										</div>
									</div>
								</div>
								<div id="auiGrid" style="margin-top: 5px; height: 665px;"></div>
							</div>
							<!-- /메뉴목록 -->
							<div class="col-7" id="normal">
								<div class="row">
									<!-- 메뉴정보 -->
									<div class="col-12">
										<div class="title-wrap mt10">
											<h4>조직정보</h4>
										</div>
										<!-- 폼테이블 -->
										<div style="margin-top: 5px; ">
											<table class="table-border">
												<colgroup>
													<col width="110px">
													<!-- 75에서 100으로수정-->
													<col width="">
													<col width="110px">
													<col width="">
												</colgroup>
												<tbody>
													<tr>
														<th class="text-right essential-item">조직코드</th>
														<td><input type="text"
															class="form-control essential-bg width100px"
															dataType="int" id="org_code" name="org_code"
															minlength="4" maxlength="4" alt="조직코드"
																   style="display: inline"
															placeholder="숫자만 입력" required="required">
															<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
															<%--<span class="text-warning">•상위조직 대리점 선택시 코드값 생성</span>--%>
															<span class="text-warning">•상위조직 위탁판매점 선택시 코드값 생성</span>
														</td>
														<th class="text-right essential-item">조직구분</th>
														<td><c:forEach var="item"
																items="${codeMap['ORG_GUBUN']}">
																<div class="form-check form-check-inline">
																	<input class="form-check-input org_gubun_cd"
																		type="radio" name="org_gubun_cd"
																		id="${item.code_value}" value="${item.code_value}"
																		${item.code_value == orgBean.org_gubun_cd ? 'checked' : '' }
																		onclick="javascript:fnChangeForm('${item.code_value}');"
																		alt="조직구분" required="required"> <label
																		for="${item.code_value}" class="form-check-label">${item.code_name}</label>
																</div>
															</c:forEach></td>
													</tr>
													<tr>
														<th class="text-right essential-item">조직명(한글)</th>
														<td><input type="text"
															class="form-control essential-bg width120px"
															name="org_kor_name" id="org_kor_name" maxlength="100"
															alt="조직명(한글)" required="required"
															style="ime-mode: active;"></td>
														<th class="text-right">조직명(영문)</th>
														<td><input type="text"
															class="form-control width120px" name="org_eng_name"
															id="org_eng_name" style="ime-mode: disabled;"></td>
													</tr>
													<tr>
														<th class="text-right essential-item">상위조직</th>
														<td><select
															class="form-control essential-bg width280px"
															id="up_org_code" name="up_org_code" alt="상위조직"
															onChange='javascript:fnChangeOrgCode(this);' required="required">
																<option value="">- 선택 -</option>
																<c:forEach var="item" items="${list}">
																	<option value="${item.org_code}" auto_new_org_yn="${item.auto_new_org_yn}">${item.org_name}</option>
																</c:forEach>
														</select></td>
														<th class="text-right essential-item">조회순번</th>
														<td><input type="text"
															class="form-control width100px essential-bg"
															name="sort_no" id="sort_no" dataType="int"
															placeholder="숫자만 입력" alt="조회순번" required="required">
														</td>
													</tr>

													<tr>
														<th class="text-right essential-item">트리노출여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="tree_show_yn" id="tree_show_y" value="Y"
																	checked="checked"> <label for="tree_show_y"
																	class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="tree_show_yn" id="tree_show_n" value="N">
																<label for="tree_show_n" class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right essential-item">사용여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="use_yn" id="use_y" value="Y" checked="checked">
																<label for="use_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="use_yn" id="use_n" value="N"> <label
																	for="use_n" class="form-check-label">N</label>
															</div>
														</td>

													</tr>

													<tr>
														<th class="text-right">전화</th>
														<td><input type="text"
															class="form-control width140px" name="tel_no" id="tel_no"
															maxlength="100" alt="URL" placeholder="-없이 숫자만">
														</td>
														<th class="text-right" rowspan="3">주소</th>
														<td>
															<div class="form-row inline-pd">
																<div class="col-3">
																	<input type="text" class="form-control width100px"
																		name="post_no" id="post_no">
																</div>
																<div class="col-auto">
																	<button type="button" class="btn btn-primary-gra"
																		onclick="javascript:openSearchAddrPanel('fnJusoBiz');">주소찾기</button>
																</div>
																<div class="col-3">
																	<input type="text" class="form-control width120px" id="addr_lng" name="addr_lng" placeholder="경도(lng)">
																</div>
																<div class="col-3">
																	<input type="text" class="form-control width120px" id="addr_lat" name="addr_lat" placeholder="위도(Lat)">
																</div>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right">팩스</th>
														<td><input type="text"
															class="form-control width140px" name="fax_no" id="fax_no"
															maxlength="100" alt="URL" placeholder="-없이 숫자만">
														</td>
														<td><input type="text"
															class="form-control width280px" name="addr1" id="addr1"
															maxlength="100" alt="URL"></td>
													</tr>
													<tr>
														<th class="text-right">부서장</th>
														<td>
															<div class="form-row inline-pd">
																<div class="col-3">
																	<input type="text" class="form-control width120px"
																		name="org_mem_name" id="org_mem_name"> <input
																		type="hidden" class="form-control" name="org_mem_no"
																		id="org_mem_no">
																</div>
																<div class="col-auto">
																	<button type="button"
																		class="btn btn-icon btn-primary-gra"
																		onclick="javascript:openSearchMemberPanel('fnSetOrgInfo');">
																		<i class="material-iconssearch"></i>
																	</button>
																</div>
															</div>
														</td>
														<td><input type="text"
															class="form-control width280px" name="addr2" id="addr2"
															maxlength="100" alt="URL"></td>
													</tr>
													<tr>
														<th class="text-right essential-item">부품기준</br>창고여부
														</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="part_warehouse_yn" id="part_warehouse_y"
																	value="Y"> <label for="part_warehouse_y"
																	class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="part_warehouse_yn" id="part_warehouse_n"
																	value="N" checked="checked"> <label
																	for="part_warehouse_n" class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right essential-item">전도금관리함</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="imprest_mng_yn" id="imprest_mng_yn_y" value="Y"
																	onchange="fnChangeImprest()"> <label
																	for="imprest_mng_yn_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="imprest_mng_yn" id="imprest_mng_yn_n" value="N"
																	checked="checked" onchange="fnChangeImprest()">
																<label for="imprest_mng_yn_n" class="form-check-label">N</label>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right essential-item">전도금 계좌번호</th>
														<td><select class="form-control width100px"
															id="imprest_bank_code" name="imprest_bank_code"
															alt="전도금 계좌번호">
																<option value="">- 선택 -</option>
																<c:forEach var="item" items="${imprestList}">
																	<option value="${item.code_value}">${item.code_name}</option>
																</c:forEach>
														</select></td>
														<th class="text-right">전도금 담당자</th>
														<td>
															<div class="form-row inline-pd">
																<div class="col-3">
																	<input type="text" class="form-control width120px"
																		name="imprest_mem_name" id="imprest_mem_name"
																		readonly="readonly"> <input type="hidden"
																		class="form-control" name="imprest_mem_no"
																		id="imprest_mem_no">
																</div>
																<div class="col-auto">
																	<button type="button" id="imprest_mem_btn"
																		class="btn btn-icon btn-primary-gra"
																		onclick="javascript:openSearchMemberPanel('fnSetImprestInfo');">
																		<i class="material-iconssearch"></i>
																	</button>
																</div>
															</div>
														</td>
													</tr>
<%--													<tr>--%>
<%--														<th class="text-right essential-item">부서권한여부</th>--%>
<%--														<td>--%>
<%--															<div class="form-check form-check-inline">--%>
<%--																<input class="form-check-input" type="radio"--%>
<%--																	name="menu_org_yn" id="menu_org_yn_y" value="Y"> --%>
<%--																<label for="menu_org_yn_y" class="form-check-label">Y</label>--%>
<%--															</div>--%>
<%--															<div class="form-check form-check-inline">--%>
<%--																<input class="form-check-input" type="radio"--%>
<%--																	name="menu_org_yn" id="menu_org_yn_n" value="N">--%>
<%--																<label for="menu_org_yn_n" class="form-check-label">N</label>--%>
<%--															</div>--%>
<%--														</td>--%>
<%--														<th class="text-right">부서권한적용직급</th>--%>
<%--														<td>--%>
<%--															<select--%>
<%--															class="form-control essential-bg width280px"--%>
<%--															id="menu_grade_cd" name="menu_grade_cd" alt="권한직급">--%>
<%--																<option value="">- 선택 -</option>--%>
<%--																<c:forEach var="item" items="${codeMap['GRADE']}">--%>
<%--																	<option value="${item.code_value}">${item.code_name}</option>--%>
<%--																</c:forEach>--%>
<%--															</select>--%>
<%--														</td>--%>
<%--													</tr>--%>
													<tr>
														<th class="text-right">더존 부서 코드</th>
														<td><input type="text"
																   class="form-control width140px" name="duzon_org_code" id="duzon_org_code"
																   maxlength="4" alt="URL" placeholder="숫자만">
														</td>
														<th class="text-right">대표이미지</th>
														<td>
															<div class="table-attfile submit_div_rep">
																<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goRepFileUploadPopup()" id="btn_submit_rep_file">파일찾기</button>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right essential-item">거래처 관리여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	   name="client_mng_yn" id="client_mng_y"
																	   value="Y"> <label for="client_mng_y"
																						 class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	   name="client_mng_yn" id="client_mng_n"
																	   value="N" checked="checked"> <label
																	for="client_mng_n" class="form-check-label">N</label>
															</div>
														</td>
														<th></th>
														<td></td>
													</tr>
												</tbody>
											</table>
										</div>
										<!-- /폼테이블 -->
										<!-- 그리드 서머리, 컨트롤 영역 -->
										<div class="btn-group mt5 section-inner active">
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
														name="pos" value="BOM_R" /></jsp:include>
											</div>
										</div>
										<!-- /그리드 서머리, 컨트롤 영역 -->
									</div>
									<!-- /메뉴정보 -->
								</div>
								<!-- 버튼정보 -->
								<div class="row section-inner-center">
									<div class="col-12">
										<div class="title-wrap">
											<h4>센터정보</h4>
										</div>
										<div>
											<table class="table-border" id="center_table">
												<colgroup>
													<col width="110px">
													<!-- 75에서 100으로수정-->
													<col width="">
													<col width="110px">
													<col width="">
												</colgroup>
												<tbody>
													<tr>
														<th class="text-right">부품/렌탈</br>담당자 번호
														</th>
														<td><input type="text"
															class="form-control width140px" name="part_tel_no"
															id="part_tel_no" maxlength="20" alt="URL"></td>
														<th class="text-right">서비스 </br>담당자 번호
														</th>
														<td><input type="text"
															class="form-control width140px" name="service_tel_no"
															id="service_tel_no" maxlength="20"></td>
													</tr>
													<tr>
														<th class="text-right">마케팅 담당자</th>
														<td>
															<div class="form-row inline-pd">
																<div class="col-3">
																	<input type="text" class="form-control width120px"
																		name="sale_mem_name" id="sale_mem_name"> <input
																		type="hidden" class="form-control" name="sale_mem_no"
																		id="sale_mem_no">
																</div>
																<div class="col-auto">
																	<button type="button"
																		class="btn btn-icon btn-primary-gra"
																		onclick="javascript:openSearchMemberPanel('fnSetSaleInfo');">
																		<i class="material-iconssearch"></i>
																	</button>
																</div>
															</div>
														</td>
														<th class="text-right essential-item">렌탈취급여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="center_rental_treat_yn"
																	id="center_rental_treat_y" value="Y"> <label
																	for="center_rental_treat_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="center_rental_treat_yn"
																	id="center_rental_treat_n" value="N" checked="checked">
																<label for="center_rental_treat_n"
																	class="form-check-label">N</label>
															</div>
														</td>
													</tr>

													<tr>
														<th class="text-right essential-item">당직관리여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="nigth_duty_yn" id="nigth_duty_y" value="Y">
																<label for="nigth_duty_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="nigth_duty_yn" id="nigth_duty_n" value="N"
																	checked="checked"> <label for="nigth_duty_n"
																	class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right essential-item">창고사용여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="center_warehouse_yn" id="center_warehouse_y"
																	value="Y"> <label for="center_warehouse_y"
																	class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="center_warehouse_yn" id="center_warehouse_n"
																	value="N" checked="checked"> <label
																	for="center_warehouse_n" class="form-check-label">N</label>
															</div>
														</td>
													</tr>

													<tr>
														<th class="text-right essential-item">장비기본입고창고<br>지정여부
														</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="machine_in_yn" id="machine_in_y" value="Y">
																<label for="machine_in_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="machine_in_yn" id="machine_in_n" value="N"
																	checked="checked"> <label for="machine_in_n"
																	class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right essential-item">HOMI 관리사업장 지정여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="homi_mng_yn" id="homi_mng_y" value="Y"> <label
																	for="homi_mng_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="homi_mng_yn" id="homi_mng_n" value="N"
																	checked="checked"> <label for="homi_mng_n"
																	class="form-check-label">N</label>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right essential-item">수요예측자료</br>제외여부
														</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="dem_fore_yn" id="dem_fore_y" value="Y"> <label
																	for="dem_fore_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="dem_fore_yn" id="dem_fore_n" value="N"
																	checked="checked"> <label for="dem_fore_n"
																	class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right essential-item">중고장비<br>취급여부
														</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="center_machine_used_yn"
																	id="center_machine_used_y" value="Y"> <label
																	for="center_machine_used_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="center_machine_used_yn"
																	id="center_machine_used_n" value="N" checked="checked">
																<label for="center_machine_used_n"
																	class="form-check-label">N</label>
															</div>
														</td>
													</tr>
												</tbody>
											</table>
										</div>
										<%-- [재호 추가개발 4차] - 전산담당 직책만 노출 --%>
										<c:if test="${page.fnc.F00048_001 eq 'Y'}">
											<div class="title-wrap">
												<h4>네트워크서비스정보</h4>
												<button type="button" class="btn btn-info" onclick="javascript:goPreview();">미리보기</button>
											</div>
											<div>
												<table class="table-border" id="network_table">
													<colgroup>
														<col width="110px">
														<!-- 75에서 100으로수정-->
														<col width="">
														<col width="110px">
														<col width="">
													</colgroup>
													<tbody>
													<tr>
														<th class="text-right essential-item">전국센터소개<br/>표시여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" name="net_show_yn" id="net_show_y" value="Y">
																<label for="net_show_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" name="net_show_yn" id="net_show_n" value="N">
																<label for="net_show_n" class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right essential-item">지도 표기 위치</th>
														<td>
															<div class="form-row inline-pd">
																<div class="col-3">
																	<input type="text" class="form-control width120px" id="net_pos_x" name="net_pos_x" placeholder="지도 표기 위치(x)">
																</div>
																<div class="col-3">
																	<input type="text" class="form-control width120px" id="net_pos_y" name="net_pos_y" placeholder="지도 표기 위치(y)">
																</div>
																<div class="form-check form-check-inline">
																	<input class="form-check-input" type="radio" name="net_name_pos_lr" id="net_name_pos_l" value="L">
																	<label for="net_name_pos_l" class="form-check-label">좌</label>
																</div>
																<div class="form-check form-check-inline">
																	<input class="form-check-input" type="radio" name="net_name_pos_lr" id="net_name_pos_r" value="R">
																	<label for="net_name_pos_r" class="form-check-label">우</label>
																</div>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right">지도 표기 이름</th>
														<td>
															<input type="text" class="form-control width120px" name="net_map_org_name" id="net_map_org_name">
														</td>
														<th class="text-right">상세 표기 이름</th>
														<td>
															<input type="text" class="form-control width120px" name="net_dtl_org_name" id="net_dtl_org_name">
														</td>
													</tr>
													</tbody>
												</table>
											</div>
										</c:if>
										<!-- 그리드 서머리, 컨트롤 영역 -->
										<div class="btn-group mt5 section-inner-center">
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
														name="pos" value="BOM_R" /></jsp:include>
											</div>
										</div>
										<!-- /그리드 서머리, 컨트롤 영역 -->
									</div>
								</div>
								<!-- /버튼정보 -->
								<!-- 버튼정보 -->
								<div class="row section-inner-franc">
									<div class="col-12">
										<div class="title-wrap">
											<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
											<%--<h4>대리점정보</h4>--%>
											<h4>위탁판매점정보</h4>
										</div>
										<div>
											<table class="table-border" id="agency_table">
												<colgroup>
													<col width="110px">
													<!-- 75에서 100으로수정-->
													<col width="">
													<col width="110px">
													<col width="">
												</colgroup>
												<tbody>
													<tr>
														<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
														<%--<th class="text-right essential-item">대리점 구분</th>--%>
														<th class="text-right essential-item">위탁판매점 구분</th>
														<td><c:forEach var="item"
																items="${codeMap['AGENCY_GUBUN']}">
																<div class="form-check form-check-inline">
																	<input class="form-check-input agency_gubun_cd"
																		type="radio" name="agency_gubun_cd"
																		id="${item.code_value}" value="${item.code_value}"
																		${item.code_value == agencyBean.agency_gubun_cd ? 'checked' : '' }
																		alt="위탁판매점 구분"> <label for="${item.code_value}"
																		class="form-check-label">${item.code_name}</label>
																</div>
															</c:forEach></td>
														<th class="text-right essential-item">마케팅구분</th>
														<td><c:forEach var="item"
																items="${codeMap['AGENCY_SALE_TYPE']}">
																<div class="form-check form-check-inline">
																	<input class="form-check-input agency_sale_type_cd"
																		type="radio" name="agency_sale_type_cd"
																		id="${item.code_value}" value="${item.code_value}"
																		${item.code_value == agencyBean.agency_sale_type_cd ? 'checked' : '' }
																		alt="마케팅 구분"> <label for="${item.code_value}"
																		class="form-check-label">${item.code_name}</label>
																</div>
															</c:forEach></td>
													</tr>
													<tr>
														<th class="text-right essential-item">렌탈취급여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="agency_rental_treat_yn"
																	id="agency_rental_treat_y" value="Y"> <label
																	for="agency_rental_treat_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="agency_rental_treat_yn"
																	id="agency_rental_treat_n" value="N" checked="checked">
																<label for="agency_rental_treat_n"
																	class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right">매출한도</th>
														<td><input type="text"
															class="form-control width100px text-right" name="max_amt"
															id="max_amt" format="decimal" maxlength="100" alt="URL"
															disabled="disabled"></td>
													</tr>
													<tr>
														<th class="text-right">보증금</th>
														<td><input type="text"
															class="form-control width100px text-right" name="bjng_amt"
															id="bjng_amt" format="decimal" maxlength="100" alt="보증금" onkeyup="javascript:fnCalc();">
														</td>
														<th class="text-right">잉여보유금</th>
														<td><input type="text"
															class="form-control width100px text-right" name="delay_amt"
															id="delay_amt" format="decimal" maxlength="100" alt="URL" onkeyup="javascript:fnCalc();">
														</td>
													</tr>

													<tr>
														<th class="text-right">담보금</th>
														<td><input type="text"
															class="form-control width100px text-right" name="dambo_amt"
															id="dambo_amt" format="decimal" maxlength="100" alt="URL" onkeyup="javascript:fnCalc();">
														</td>
														<th class="text-right">이관료</th>
														<td><input type="text"
															class="form-control text-right width100px" name="service_amt"
															id="service_amt" format="decimal" maxlength="100"
															alt="URL"></td>
													</tr>
													<tr>
														<th class="text-right essential-item">창고사용여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="agency_warehouse_yn" id="agency_warehouse_y"
																	value="Y"> <label for="agency_warehouse_y"
																	class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="agency_warehouse_yn" id="agency_warehouse_n"
																	value="N" checked="checked"> <label
																	for="agency_warehouse_n" class="form-check-label">N</label>
															</div>
														</td>
														<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
														<%--<th class="text-right essential-item">대리점재고조회<br>합산표시여부--%>
														<th class="text-right essential-item">위탁판매점재고조회<br>합산표시여부
														</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="stock_sum_yn" id="stock_sum_y" value="Y">
																<label for="stock_sum_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="stock_sum_yn" id="stock_sum_n" value="N"
																	checked="checked"> <label for="stock_sum_n"
																	class="form-check-label">N</label>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right">월정산보류여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="mon_accounts_hold_yn" id="mon_accounts_hold_y"
																	value="Y"> <label for="mon_accounts_hold_y"
																	class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="mon_accounts_hold_yn" id="mon_accounts_hold_n"
																	value="N" checked="checked"> <label
																	for="mon_accounts_hold_n" class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right">거래정지여부</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	onclick="javascript:fnChangeStopYn('Y');"
																	name="stop_yn" id="stop_y" value="Y"> <label
																	for="stop_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	onclick="javascript:fnChangeStopYn('N');"
																	name="stop_yn" id="stop_n" value="N" checked="checked">
																<label for="stop_n" class="form-check-label">N</label>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right">중고장비<br>취급여부
														</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="agency_machine_used_yn"
																	id="agency_machine_used_y" value="Y"> <label
																	for="agency_machine_used_y" class="form-check-label">Y</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio"
																	name="agency_machine_used_yn"
																	id="agency_machine_used_n" value="N" checked="checked">
																<label for="agency_machine_used_n"
																	class="form-check-label">N</label>
															</div>
														</td>
														<th class="text-right rs">지사장</th>
														<td>
															<div class="form-row inline-pd">
																<div class="col-3">
																	<input type="text" class="form-control width120px" name="cust_name" id="cust_name" size="20" maxlength="20" alt="지사장" readonly="readonly" style="text-decoration: underline;text-underline-position: under;"
																	onclick="javascript:goCustDetail()">
																	<input type="hidden" class="form-control" name="cust_no" id="cust_no">
																</div>
																<div class="col-auto">
																	<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetAgencyMaster');">
																		<i class="material-iconssearch"></i>
																	</button>
																</div>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right">위탁판매점계약일자</th>
														<td>
															<div class="input-group">
																<input type="text" class="form-control calDate" id="sale_contract_dt" name="sale_contract_dt" onChange="javascript:fnSetDefaultContractDate();" dateFormat="yyyy-MM-dd">
																<div class="col-auto"> ~ </div>
																<input type="text" class="form-control calDate" id="sale_contract_ed_dt" name="sale_contract_ed_dt" dateFormat="yyyy-MM-dd">
															</div>
														</td>
														<th class="text-right rs">마케팅능력</th>
														<td>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" name="sale_ability_hmb" id="sale_ability_hmb_h" value="H">
																<label for="sale_ability_hmb_h" class="form-check-label">상</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" name="sale_ability_hmb" id="sale_ability_hmb_m" value="M">
																<label for="sale_ability_hmb_m" class="form-check-label">중</label>
															</div>
															<div class="form-check form-check-inline">
																<input class="form-check-input" type="radio" name="sale_ability_hmb" id="sale_ability_hmb_b" value="B">
																<label for="sale_ability_hmb_b" class="form-check-label">하</label>
															</div>
														</td>
													</tr>
													<tr>
														<th class="text-right">계약서업로드</th>
														<td colspan="3">
															<div class="table-attfile submit_div">
																<button type="button" class="btn btn-primary-gra mr10" onclick="javascript:goFileUploadPopup()" id="btn_submit">파일찾기</button>
															</div>
														</td>
													</tr>
												</tbody>
											</table>
										</div>
										<!-- 그리드 서머리, 컨트롤 영역 -->
										<div class="btn-group mt5 section-inner-franc">
											<div class="right">
												<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param
														name="pos" value="BOM_R" /></jsp:include>
											</div>
										</div>
										<!-- /그리드 서머리, 컨트롤 영역 -->
									</div>
								</div>
								<!-- /버튼정보 -->
							</div>
							<div class="col-7 dpn" id="monitor">
								<div class="title-wrap mt10">
									<h4>모니터/서브딜러 정보</h4>
									<div class="btn-group">
										<div class="right">
											<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
												<label onclick="javascript:goSearchMonitorSubList()"><input type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >마스킹 적용</label>
											</c:if>
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
										</div>
									</div>
								</div>
								<div id="auiGridMonitor" style="width: 100%; height: 555px; margin-top: 5px; "></div>
								<div class="btn-group mt5">
									<div class="right">
										<button type="button" id="_goSaveMonitor" class="btn btn-info" onclick="javascript:goSaveMonitor();">저장</button>
									</div>
								</div>
							</div>
							<div class="col-7 dpn" id="agencylist">
								<div class="title-wrap mt10">
									<%-- [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체 --%>
									<%--<h4>대리점 정보</h4>--%>
									<h4>위탁판매점 정보</h4>
									<div class="btn-group">
										<div class="right">
											<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
												<label onclick="javascript:goSearchAgencyList()"><input type="checkbox" id="s_a_masking_yn" name="s_a_masking_yn" checked="checked" value="Y">마스킹 적용</label>
											</c:if>
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
										</div>
									</div>
								</div>
								<div id="auiGridAgency" style="width: 100%; height: 555px; margin-top: 5px; "></div>
							</div>
						</div>
					</div>
				</div>
				<jsp:include page="/WEB-INF/jsp/common/footer.jsp" />
			</div>
			<!-- /contents 전체 영역 -->
		</div>
	</form>
</body>
</html>
