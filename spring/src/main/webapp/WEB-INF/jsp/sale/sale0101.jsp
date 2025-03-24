<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 계약관리 > 계약/출하 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2019-12-19 14:23:48
-- 출하예정일 다시 추가(Q&A에 올라옴)
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
// 		var testJsonData = [{'MB00000431':{'test':'ttttt','test2':'tttt123'}},{'MB00000501':{'test':'123321','test2':'aaa123'}}];
		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var dataFieldName = []; // 펼침 항목(create할때 넣음)
		var machineGroupByMaker = ${machineGroupByMaker}
		var machineList = ${machineList}
	
		$(document).ready(function() {
			createAUIGrid();
			fnInit();
		});
		
		// 간편등록
		function goNew() {
			var poppupOption = "";
			var url = "/sale/sale0101p15";
			var param = {};
			$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		// 출하캘린더 팝업
		function goOutCalPopup() {
			var poppupOption = "";
			var url = "/sale/sale0101p13";
			var param = {};
			$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
		}	
		
		function fnChangeMakerCd() {
			$('#s_machine_plant_seq').combogrid("reset");
			var makerCd = $M.getValue("s_maker_cd");
			var list = [];
			if (makerCd != "") {
				list = machineGroupByMaker[makerCd];
			} else {
				list = machineList;
			}
			$M.reloadComboData("s_machine_plant_seq", list);
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
		
		function fnInit() {
			/* var now = "${inputParam.s_current_dt}";
			$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -3)); */
			goSearch();
		}
		
		// 페이지 이동
		function goNewContract() {
			$M.goNextPage("/sale/sale010101");
		}
		
		function goNewStock() {
			$M.goNextPage("/sale/sale010102");
		}
		
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
					  exceptColumnFields : ["docBtn", "outDocBtn"]
			  };
			  fnExportExcel(auiGrid, "계약출하내역", exportProps);
		}
		
		function fnMyExecFuncName(data) {
	        $M.setValue("s_mem_no", data.mem_no);
	    }
		
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_doc_mem_name", "s_only_machine_doc"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
		
		// 조회
		function goSearch() { 
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		function fnSearch(successFunc) {
			if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
				return;
			}; 
			if ($M.getValue("s_gubun_complete_yn") == "1") {
				if ($M.getValue($M.getValue("s_start_dt") == "") || $M.getValue($M.getValue("s_end_dt") == "")) {
					alert("출하종결 검색시 일자를 입력하세요.");
					return false;
				}
			}
			isLoading = true;
			var param = {
				s_date_type : $M.getValue("s_date_type"), // out_dt : 출하일자 / reg_dt : 등록일자
				s_doc_start_dt : $M.getValue("s_start_dt"),
				s_doc_end_dt : $M.getValue("s_end_dt"),
				s_gubun_all_yn : $M.getValue("s_gubun_all_yn"), // 모두 해제 시, 작성중
				s_gubun_ongoing_yn : $M.getValue("s_gubun_ongoing_yn"), // 결재 진행중
				s_gubun_paid_yn : $M.getValue("s_gubun_paid_yn"), // 미입금자료
				s_gubun_complete_yn : $M.getValue("s_gubun_complete_yn"), // 출하종결
				s_gubun_hold_yn : $M.getValue("s_gubun_hold_yn"), // 출하보류
				s_gubun_cancel_yn : $M.getValue("s_gubun_cancel_yn"), // 계약취소
				s_mch_type_cad_c_yn : $M.getValue("s_mch_type_cad_c_yn"), // 건기
				s_mch_type_cad_a_yn : $M.getValue("s_mch_type_cad_a_yn"), // 농기
				s_machine_name : $M.getValue("s_machine_name"), // 모델명
				s_machine_plant_seq : $M.getValue("s_machine_plant_seq"),
				s_maker_cd : $M.getValue("s_maker_cd"), // 메이커 (ASIS 하드코딩 -> TOBE 코드테이블)
				s_machine_doc_appr_status : $M.getValue("s_machine_doc_appr_status"), // 결재상태 (ASIS RADIO -> TOBE SELECT BOX)
				s_doc_mem_name : $M.getValue("s_doc_mem_name"),
				/* s_cust_no : $M.getValue("s_cust_no"), */
				s_cust_name : $M.getValue("s_cust_name"),
				s_machine_out_status : $M.getValue("s_machine_out_status"),
				s_sort_key : "request_appr_dt desc nulls last, machine_doc_no",
				s_sort_method : "desc",
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				s_only_machine_doc : $M.getValue("s_only_machine_doc"),
				"page" : page,
				"rows" : $M.getValue("s_rows")
			}
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					isLoading = false;
					if(result.success) {
						successFunc(result);
					};
				}
			); 
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}
		
		// 전체
		function fnChangeGubunAll() {
			if($M.getValue("s_gubun_all_yn") == "Y") {
				var param = {
						s_gubun_all_yn : "Y",
						s_gubun_ongoing_yn : "Y",
						s_gubun_paid_yn : "Y",
						s_gubun_complete_yn : "Y",
						s_gubun_hold_yn : "Y",
						s_gubun_cancel_yn : "Y", 
						s_mch_type_cad_c_yn : "Y", 
						s_mch_type_cad_a_yn : "Y", 
						s_machine_doc_appr_status : ""
				}
				$M.setValue(param);
			} else {
				var param = {
						s_gubun_all_yn : "",
						s_gubun_ongoing_yn : "",
						s_gubun_paid_yn : "",
						s_gubun_complete_yn : "",
						s_gubun_hold_yn : "",
						s_gubun_cancel_yn : "",
						s_mch_type_cad_c_yn : "", 
						s_mch_type_cad_a_yn : ""
				}
				$M.setValue(param);
			}
		}
		
		// 구분변경
		function fnChangeGubun() {
			var s_gubun_all_yn = $M.getValue("s_gubun_all_yn");
			var s_gubun_ongoing_yn = $M.getValue("s_gubun_ongoing_yn");
			var s_gubun_paid_yn = $M.getValue("s_gubun_paid_yn");
			var s_gubun_complete_yn = $M.getValue("s_gubun_complete_yn"); // 출하종결
			var s_gubun_hold_yn = $M.getValue("s_gubun_hold_yn");
			var s_gubun_cancel_yn = $M.getValue("s_gubun_cancel_yn");
			var s_mch_type_cad_c_yn = $M.getValue("s_mch_type_cad_c_yn");
			var s_mch_type_cad_a_yn = $M.getValue("s_mch_type_cad_a_yn");
			
			if(s_gubun_ongoing_yn == "Y" && s_gubun_paid_yn == "Y" && s_gubun_complete_yn == "Y" && s_gubun_hold_yn == "Y" && s_gubun_cancel_yn == "Y" && s_mch_type_cad_c_yn == "Y" && s_mch_type_cad_a_yn == "Y") {
				$M.setValue("s_gubun_all_yn", "Y");
			} else {
				$M.setValue("s_gubun_all_yn", "");
			}
			if(s_gubun_complete_yn == "Y") {
				$M.setValue("s_date_type", "out_dt");
			} else {
				$M.setValue("s_date_type", "reg_dt");
			}
		}
		
		function goMachineDoc(rowIndex) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			var param = {
				machine_doc_no : item.machine_doc_no
			}
			// 출하지 서비스센터인 경우 해당 출하지가 아니라면 상세정보를 볼수없다
			var loginOrgCode = "${SecureUser.org_code}";
			var loginMemNo = "${SecureUser.mem_no}";
			if (loginOrgCode.substr(0, 1) == "5" && loginOrgCode.substr(0, 2) != "50" && loginMemNo != item.doc_mem_no) {
				// 사용자의 센터에 해당 품의서 장비를 보유하고 있는지 확인
				if ($M.toNum(item.in_cnt) == 0) {
					// [14669] 출하센터(평택(5110)/대구(5120)/김해(5200)/옥천(5240))의 직원은 열람할 수 있게 변경 - 김경빈
					if ('${page.fnc.F00066_004}' != 'Y') {
						if (item.out_dt != "") {
							if (${page.add.OUT_NOT_END_CENTER_SEARCH_YN ne 'Y'}) {
								if (loginOrgCode != item.out_org_code) {
									alert("다른 출하지입니다.");
									return false;
								}
							}
						} else if (loginOrgCode != item.out_org_code){
							alert("다른 출하지입니다.");
							return false;
						}
					}
				}
			} 
			var poppupOption = "";
			var url = '/sale/sale0101p01';
			if (item.machine_doc_type_cd == "STOCK") {
				url = '/sale/sale0101p09';
			} 
			$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		function goMachineOutDoc(rowIndex) {
			var item = AUIGrid.getItemByRowIndex(auiGrid, rowIndex);
			var param = {
				machine_doc_no : item.machine_doc_no
			}
			// 출하지 서비스센터인 경우 해당 출하지가 아니라면 상세정보를 볼수없다
			var loginOrgCode = "${SecureUser.org_code}";
			var loginMemNo = "${SecureUser.mem_no}";
			if (loginOrgCode.substr(0, 1) == "5" && loginOrgCode.substr(0, 2) != "50" && loginMemNo != item.doc_mem_no) {
				if (item.out_dt != "") {
					if (${page.add.OUT_NOT_END_CENTER_SEARCH_YN ne 'Y'}) {
						if (loginOrgCode != item.out_org_code) {
							alert("다른 출하지입니다.");
							return false;
						}
					}
				} else if (loginOrgCode != item.out_org_code){
					alert("다른 출하지입니다.");
					return false;
				}
			} 
			var poppupOption = "";
			var url = '/sale/sale0101p03';
			if (item.machine_doc_type_cd == "STOCK") {
				url = '/sale/sale0101p09';
				$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
			} else {
				if ($M.toNum(item.machine_doc_status_cd) < 2) {
					alert("품의서 결재 이후 출하의뢰서를 등록 할 수 있습니다.");
					return false;
				} else {
					if (item.machine_out_doc_seq == "" && item.doc_mem_no != "${SecureUser.mem_no}") {
						alert("출하의뢰서 미작성 상태이기 때문에\n계약담당자만 처리 가능합니다");
						return false;
					}
				}
				$M.goNextPage(url, $M.toGetParam(param), {popupStatus : poppupOption});
			}
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				/* showSelectionBorder : false, */ 
				rowIdField : "machine_doc_no",
				rowIdTrustMode : true,
				height : 555,
				//툴팁 출력 지정
				showTooltip : true,
				//툴팁 마우스 오버 후 100ms 이후 출력시킴. 
				tooltipSensitivity : 100,
				rowStyleFunction : function(rowIndex, item) {
					var style = "";
					if (item.aui_status_cd !== "") {
						if(item.aui_status_cd == "D") { // 기본
							style = "aui-status-default";
						} else if(item.aui_status_cd == "P") { // 진행예정
							style = "aui-contract-reject";
						} else if(item.aui_status_cd == "G") { // 진행중
							style = "aui-status-ongoing";
						} else if(item.aui_status_cd == "R") { // 반려
							style = "aui-status-reject-or-urgent";
						} else if(item.aui_status_cd == "C") { // 완료
							style = "aui-status-complete";
						}
					}
					if (item.appr_history_cnt != 1 && item.aui_status_cd != "C") {
						style = "aui-contract-reject";
					}
					if (item.aui_status_cd == "R") {
						return "aui-status-reject-or-urgent";
					}
					if (item.print_cnt != 0) {
						return "aui-contract-print";
					}
					return style;
				}
			};
			var dtWidth = "70";
			var columnLayout = [
				{ 
					dataField : "machine_doc_type_cd", 
					visible : false
				},
				{ 
					dataField : "display_org_name", 
					visible : false
				},
				{ 
					dataField : "s_mem_no", 
					visible : false
				},
				{ 
					headerText : "관리번호", 
					dataField : "machine_doc_no", 
					width : "70",
					minWidth : "65",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
		                  var ret = "";
		                  if (value != null && value != "") {
		                     ret = value.split("-");
		                     ret = ret[0]+"-"+ret[1];
		                     ret = ret.substr(4, ret.length);
		                  }
		                   return ret; 
		               }, 
				},
				{ 
					headerText : "품의일", 
					dataField : "doc_dt", 
					dataType : "date",   
					width : dtWidth, 
					minWidth : "65",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "담당자", 
					dataField : "doc_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					tooltip : {
						tooltipFunction : fnShowAuigridTooltip
					},
				},
				{
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "90",
					minWidth : "60",
					// [14669] STOCK 건 제외한 셀 스타일 변경 - 김경빈
					styleFunction : function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item.machine_doc_type_cd != "STOCK") {
							return "aui-popup";
						}
						return "aui-center";
					},
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						var ret = value;
						if (item.machine_doc_type_cd == "STOCK") {
							ret = item.display_org_name;
						}
					    return ret;
					},
				},
				{
					headerText : "장비계약", 
					dataField : "mch_type_cad", 
					width : "60",
					minWidth : "60",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					    return value == "" || value == "D" ? "" : value == "C" ? "건기" : "농기"; 
					},
					style : "aui-center",
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "90",
					minWidth : "60", 
					style : "aui-center",
				},
				{ 
					headerText : "차대번호", 
					headerStyle : "aui-fold",
					dataField : "body_no", 
					width : "120",
					minWidth : "60", 
					style : "aui-center",
				},
				{ 
					headerText : "엔진번호",
					headerStyle : "aui-fold",
					dataField : "engine_no_1", 
					width : "60",
					minWidth : "60", 
					style : "aui-center",
				},
				{ 
					headerText : "인도예정", 
					headerStyle : "aui-fold",
					dataField : "pending_receive_plan_dt", 
					dataType : "date",   
					width : dtWidth, 
					minWidth : "65",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "결재상신", 
					headerStyle : "aui-fold",
					dataField : "request_appr_dt", 
					width : dtWidth, 
					dataType : "date",   
					minWidth : "65",
					formatString : "yy-mm-dd",
					style : "aui-center",
				},
				{ 
					headerText : "결재", 
					dataField : "appr_status_name",
					width : "65",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "작업창 구분", 
					dataField : "docBtn", 
					style : "aui-center",
					width : "145", 
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = '<div class="my_div">';	
						template += '<div class="aui-grid-renderer-base" style="padding: 0px 4px; white-space: nowrap; display: inline-block; width: 45%; max-height: 24px;">';
						template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goMachineDoc(' + rowIndex + ')">품의서</span></div>'
						template += '<div class="aui-grid-renderer-base" style="padding: 0px 4px; white-space: nowrap; display: inline-block; width: 45%; max-height: 24px;">';
						template += '<span class="aui-grid-button-renderer aui-grid-button-percent-width" onclick="javascript:goMachineOutDoc(' + rowIndex + ')">출하의뢰서</span></div>'
						template += '</div>'
						return template; // HTML 형식의 스트링
					},
				},
				{ 
					headerText : "출하센터", 
					dataField : "out_org_name", 
					width : "60",
					minWidth : "50",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var ret = value;
						if (item.machine_out_doc_seq != "" && value == null) {
							console.log(item.machine_out_doc_seq);
							ret = "기타센터";
						}
						return ret;
					},
					style : "aui-center",
				},
				{ 
					headerText : "출하의뢰", 
					dataField : "request_out_dt", 
					dataType : "date",   
					width : dtWidth, 
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var ret = value;
						if (ret != null && item.machine_doc_status_cd >= 1) {
							ret = ret.substr(2, 9);
						} 
						return ret; // HTML 형식의 스트링
					},
					tooltip : {
						show : false 
					},
				},
				{
					dataField : "machine_out_status_cd",
					visible : false
				},
				{ 
					headerText : "관리확인", 
					dataField : "confirm_dt", 
					dataType : "date",   
					width : dtWidth, 
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						if (item.machine_doc_type_cd == 'STOCK') {
							if (value != null) {
								return value.substr(2, 9);
							}
						} else {
							if ($M.toNum(item.machine_out_status_cd) > 1) {
								if (value != null) {
									return value.substr(2, 9);
								}
							}
						}
					},
				},
				{ 
					headerText : "출하예정",
					dataField : "receive_plan_dt", 
					dataType : "date",   
					width : dtWidth, 
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				/* asis처럼 출하처리중도 들어갈수있게 */
				{ 
					headerText : "출하일", 
					dataField : "out_dt", 
					width : dtWidth, 
					dataType : "date",
					formatString : "yy-mm-dd",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "발송", 
					dataField : "out_paper_send_dt", // 서류 발송 관련 개발 추가해야함(asis : salessendpaperdateform)
					dataType : "date",   
					width : dtWidth, 
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
        {
          headerText : "장비인수증",
          dataField : "accep_file_yn",
          labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
            if (value == "N") {
              return "";
            } else {
              return "제출";
            }
          },
          renderer : { // HTML 템플릿 렌더러 사용
            type : "TemplateRenderer"
          },
          width : "80",
          minWidth : "60",
        },
				{ 
					headerText : "DI리포트", 
					dataField : "file_seq",
          headerStyle : "aui-fold",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if (value == "0" || value == "") {
							return "";
						}
						return "제출";
					},
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					}, 
					labelFunction : function (rowIndex, columnIndex, value, headerText, item ) { // HTML 템플릿 작성
						var template = '';	
						
						if(value != 0 && value != ""){
							if(item.pass_ypn == 'Y'){
								template += '<div style="color:#f00;">제출</div>';
							}else{
								template += '<div>제출</div>';
							}
						}
						
						return template; // HTML 형식의 스트링
					},
					width : "80", 
					minWidth : "60",
				},
				{ 
					headerText : "비고", 
					dataField : "remark", 
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var ret = value;
						if (item.machine_doc_type_cd == "STOCK") {
							ret = value + " [STOCK]";
							if (item.machine_doc_status_cd == "6") {
								ret = value + " [STOCK]회수";
							}
						}
						return ret;
					},
					width : "100", 
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "연락처", 
					headerStyle : "aui-fold",
					dataField : "hp_no", 
					width : "100",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "우편번호", 
					headerStyle : "aui-fold",
					dataField : "post_no", 
					width : "70",
					minWidth : "65",
					style : "aui-center",
				},
				{ 
					headerText : "메이커", 
					headerStyle : "aui-fold",
					dataField : "maker_name", 
					width : "70",
					minWidth : "60",
					style : "aui-center",
				},
				{ 
					headerText : "주소", 
					headerStyle : "aui-fold",
					dataField : "full_addr", 
					width : "200",
					minWidth : "75",
					style : "aui-left",
				},
				{ 
					headerText : "납입점검일", 
					dataField : "as_dt", 
					dataType : "date",   
					width : dtWidth, 
					minWidth : "75",
					style : "aui-center",
					formatString : "yy-mm-dd",
				},
				{ 
					headerText : "부서", 
					headerStyle : "aui-fold",
					dataField : "doc_org_name",
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{ 
					headerText : "상태", 
					headerStyle : "aui-fold",
					dataField : "machine_doc_status_name", 
					width : "75",
					minWidth : "75",
					style : "aui-center",
				},
				{
					dataField : "machine_doc_status_cd",
					visible : false
				},
				{
					dataField : "doc_mem_no",
					visible : false
				},
				{
					dataField : "out_org_code",
					visible : false
				},
				{
					dataField : "in_cnt",
					visible : false
				},
				{
					dataField : "cust_no",
					visible : false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", initColumnLayout(columnLayout), gridPros);
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

			// [14669] 고객명 셀 클릭 시, 고객정보상세 팝업 노출 (STOCK 제외) - 김경빈
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == 'cust_name' && event.item.machine_doc_type_cd != "STOCK"){
					$M.goNextPage('/cust/cust0102p01', $M.toGetParam({cust_no : event.item["cust_no"]}), {popupStatus : ""});
				}
			});
			
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>
								<col width="50px">
								<col width="80px">
								<col width="60px">
								<col width="140px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="60px">
								<col width="120px">
								<col width="60px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<td colspan="2">
										<select class="form-control" name="s_date_type">
											<option value="reg_dt">등록일자</option>
											<option value="out_dt">출하일자</option>
										</select>
									</td>
									<td colspan="3" style="min-width: 260px">
										<div class="form-row inline-pd">
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일자" value="${searchDtMap.s_start_dt }">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col-5">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" alt="종료일자" value="${searchDtMap.s_end_dt }">
												</div>
											</div>
											<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
					                     		<jsp:param name="st_field_name" value="s_start_dt"/>
					                     		<jsp:param name="ed_field_name" value="s_end_dt"/>
					                     		<jsp:param name="click_exec_yn" value="Y"/>
					                     		<jsp:param name="exec_func_name" value="goSearch();"/>
					                     	</jsp:include>
										</div>
									</td>
									<td colspan="9">
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_gubun_all_yn" name="s_gubun_all_yn" value="Y" onclick="javascript:fnChangeGubunAll()">
											<label class="form-check-label" for="s_gubun_all_yn">전체</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" checked="checked" id="s_gubun_ongoing_yn" name="s_gubun_ongoing_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_ongoing_yn">진행중</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" checked="checked" id="s_gubun_paid_yn" name="s_gubun_paid_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_paid_yn">입금자료</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_gubun_complete_yn" name="s_gubun_complete_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_complete_yn">출하종결</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_gubun_hold_yn" name="s_gubun_hold_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_hold_yn">출하보류</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_gubun_cancel_yn" name="s_gubun_cancel_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_gubun_cancel_yn">계약취소</label>
										</div>
										
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_mch_type_cad_c_yn" name="s_mch_type_cad_c_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_mch_type_cad_c_yn">건설기계</label>
										</div>
										<div class="form-check form-check-inline checkline">
											<input class="form-check-input" type="checkbox" id="s_mch_type_cad_a_yn" name="s_mch_type_cad_a_yn" value="Y" onclick="javascript:fnChangeGubun()">
											<label class="form-check-label" for="s_mch_type_cad_a_yn">농기계</label>
										</div>
										<c:if test="${page.fnc.F00066_002 eq 'Y'}">
											<div style="display: inline-block; ">
												<input type="search" style="width: 135px; padding: 4px;" class="form-control" placeholder="21-0001 또는 MC2021-0001" name="s_only_machine_doc" id="s_only_machine_doc" title="입력 시, 다른 조건 무시하고 관리번호로만 조회"
												onkeyup=" var start = this.selectionStart; var end = this.selectionEnd; this.value = this.value.toUpperCase(); this.setSelectionRange(start, end); ">
											</div>
										</c:if>
									</td>									
								</tr>
								<tr>
									<th>메이커</th>
									<td>
										<select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="fnChangeMakerCd()">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델</th>
									<td>
										<%-- <jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
				                     		<jsp:param name="required_field" value="s_machine_name"/>
				                     		<jsp:param name="s_maker_cd" value=""/>
				                     		<jsp:param name="s_machine_type_cd" value=""/>
				                     		<jsp:param name="s_sale_yn" value=""/>
				                     		<jsp:param name="readonly_field" value=""/>
				                     	</jsp:include> --%>
				                     	<!-- <input type="text" class="form-control" id="s_machine_name" name="s_machine_name"> -->
				                     	<!-- <select id="s_machine_name" name="s_machine_name" class="form-control">
											<option value="">- 전체 -</option>
										</select> -->
										<input type="text" style="width : 140px;"
											id="s_machine_plant_seq" 
											name="s_machine_plant_seq" 
											easyui="combogrid"
											header="N"
											easyuiname="machineName" 
											panelwidth="140"
											maxheight="300"
											textfield="machine_name"
											multi="N"
											enter="goSearch()"
											idfield="machine_plant_seq" />
									</td>
									<th>결재상태</th>
									<td>
										<select class="form-control" id="s_machine_doc_appr_status" name="s_machine_doc_appr_status">
											<option value="">- 전체 -</option>
											<option value="0">작성중</option>
											<option value="1">결재요청</option>
											<option value="2">결재완료</option>
										</select>
									</td>
									<th>출하상태</th>
									<td>
										<select class="form-control" id="s_machine_out_status" name="s_machine_out_status">
											<option value="">- 전체 -</option>
											<option value="2">출하처리중</option>
											<!-- <option value="3">출하완료</option> -->
										</select>
									</td>
									<th>담당자명</th>
									<td>
										<%-- <jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
				                     		<jsp:param name="required_field" value=""/>
				                     		<jsp:param name="s_org_code" value=""/>
				                     		<jsp:param name="s_work_status_cd" value=""/>
				                     		<jsp:param name="execFuncName" value="fnMyExecFuncName"/>
			 	                     		<jsp:param name="readonly_field" value=""/> 
				                     	</jsp:include> --%>
				                     	<input type="text" class="form-control" id="s_doc_mem_name" name="s_doc_mem_name">
									</td>
									<th>고객명</th>
									<td>
										<%-- <jsp:include page="/WEB-INF/jsp/common/searchCust.jsp">
				                     		<jsp:param name="required_field" value=""/>
			 	                     		<jsp:param name="execFuncName" value=""/>
			 	                     		<jsp:param name="focusInFuncName" value=""/>
				                     	</jsp:include> --%>
				                     	<input type="text" class="form-control" id="s_cust_name" name="s_cust_name">
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>									
								</tr>											
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회내역</h4>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
									<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</c:if>
								<label for="s_toggle_column" style="color:black;">
									<input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침
								</label>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /그리드 타이틀, 컨트롤 영역 -->					

					<div id="auiGrid" style="margin-top: 5px;width: 100%; height: 555px; position: relative;"></div>

<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>
						
			</div>		
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>