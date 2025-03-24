<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 고객 > 고객현황 > ARS > null > null
-- 작성자 : 이강원
-- 최초 작성일 : 2023-08-11 09:47:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript" src="/static/js/yk_ntsconnect.min.js?ver=20230701017"></script>
	<script type="text/javascript">

		var auiGrid;
		var page = 1;
		var moreFlag = "N";
		var isLoading = false;
		var popupWin = null;
		// 전화 걸려올 당시 ARS 상담관리에 포커스를 줘서 확인했는지 체크용 flag
		var callingFocusCheck = false;
		// 전화걸기를 통해 전화한 경우 상담관리 refresh를 안하기 위한 flag
		var callingCheck = false;
		// 전환을 통해 전화가 오는 경우 전화기 상태가 RING, 상담원 상태는 8에서
		// 전화를 받아도 상담원 상태는 8 전화기 상태가 "" 이므로 체크용 flag
		var transCheck = false;

		$(document).ready(function() {
			createAUIGrid();
			fnAgListRefresh('Y');

			setInterval(fnAutoRefresh, 1000 * 60 * 5);	// 5분마다 조회
			// goSearch();	-- 날짜셋팅전이라 날짜가 안넘어가서 하단에 위치
		});

		// 조회
		function goSearch() {
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#receive_cnt").html("수신완료 " +result.receive_cnt);
				$("#cut_cnt").html("절단호" +result.cut_cnt);
				$("#giveup_cnt").html("포기호 " +result.giveup_cnt);
				$("#callback_cnt").html("콜백요청 " +result.callback_cnt);
				$("#curr_cnt").html(result.list.length);
				$("#total_cnt").html(result.total_cnt);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}

		function fnSearch(successFunc) {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {
				return;
			};
			isLoading = true;
			var param = {
				s_cust_name : $M.getValue("s_cust_name"),
				s_org_name : $M.getValue("s_org_name"),
				s_hp_no : $M.getValue("s_hp_no"),
				s_mem_name : $M.getValue("s_mem_name"),
				s_start_dt : $M.getValue("s_start_dt"),
				s_end_dt : $M.getValue("s_end_dt"),
				s_call_gubun : $M.getValue("s_call_gubun"),
				s_complete_yn : $M.getValue("s_complete_yn"),
				s_receive_yn : $M.getValue("s_receive_yn") == "Y" ? "Y" : "N",
				s_masking_yn : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
				page : page,
				rows : $M.getValue("s_rows"),
				no_result_show_yn : $M.getValue('s_auto_refresh_yn') == "Y" ? "N" : "Y"
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			if (param.s_start_dt == "" && param.s_end_dt == "") {
				delete param['s_st_dt'];delete param['s_ed_dt'];
			}
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
					function(result) {
						isLoading = false;
						if(result.success) {
							successFunc(result);
						};
					}
			)
		}

		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
				goMoreData();
			};
		}

		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;
				if (result.list.length > 0) {
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				enableFilter :true,
				rowIdField : "_$uid",
				rowIdTrustMode : true,
				showRowNumColumn: true,
				rowStyleFunction : function(rowIndex, item) {
					if (item.complete_gubun == "Y") {
						return "aui-status-complete";
					}
				}
			};
			var columnLayout = [
				{
					headerText : "수신일시",
					dataField : "ars_date",
					dataType : "date",
					width : "100",
					minWidth : "100",
					formatString : "yy-mm-dd HH:MM",
					style : "aui-center",
				},
				{
					headerText : "구분 1",
					dataField : "call_gr_nm",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "구분 2",
					dataField : "call_svc_nm",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "위치동의",
					dataField : "agree_loc_yn",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == "Y") {
							return "O";
						} else {
							return "X";
						}
					},
				},
				{
					headerText : "발신전화번호",
					dataField : "send_hp_no",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return $M.phoneFormat(value);
					},
				},
				{
					headerText : "수신전화번호",
					dataField : "call_telnum",
					width : "120",
					minWidth : "120",
					style : "aui-center aui-link",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						return $M.phoneFormat(value);
					},
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "콜백요청번호",
					dataField : "cb_telnum",
					width : "120",
					minWidth : "120",
					style : "aui-center aui-link",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == undefined || value == null) {
							return ;
						} else if(value.length >= 8) {
							return $M.phoneFormat(value);
						}
						return value;
					},
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "최종수신위치",
					dataField : "call_enc_1",
					width : "120",
					minWidth : "120",
					style : "aui-center",
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "고객등급",
					dataField : "cust_grade_cd_str",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "미수금",
					dataField : "ed_misu_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "80",
					minWidth : "80",
					style : "aui-right",
				},
				{
					headerText : "최초상담부서",
					dataField : "org_name",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "현재상담부서",
					dataField : "ars_org_name",
					width : "100",
					minWidth : "100",
					style : "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "상담직원",
					dataField : "asr_mem_name",
					width : "80",
					minWidth : "80",
					style : "aui-center",
				},
				{
					headerText : "상담전화(내선)",
					dataField : "call_inlinenum",
					width : "100",
					minWidth : "100",
					style : "aui-center",
				},
				{
					headerText : "수신상태",
					dataField : "call_gubun",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					filter: {
						showIcon: true
					}
				},
				{
					headerText : "처리구분",
					dataField : "complete_gubun",
					width : "80",
					minWidth : "80",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == "Y") {
							return "처리완료";
						} else if(value == "N"){
							return "미 처리";
						}
						return "";
					},
				},
			];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// AUIGrid.setFixedColumnCount(auiGrid, 9);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

			// 상세팝업
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				//차대번호셀 선택한 경우 
				if (event.dataField == "call_telnum" || event.dataField == "cb_telnum") {
					if(event.value == "") {
						return;
					}

					var param = {
						hp_no : $M.removeHyphenFormat(event.item.call_telnum),
					}

					$M.goNextPage('/cust/cust0108p01', $M.toGetParam(param), {popupStatus : ''})
				}
			});
		}

		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_hp_no", "s_cust_name", "s_mem_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}

		function fnDownloadExcel() {
			var exportProps = {};
			fnExportExcel(auiGrid, "ARS 조회목록", exportProps);
		}

		function fnRefresh() {
			window.location.reload();
		}

		function goDataSearch() {
			var param = {

			};

			openSearchCustPanel('openCustArsPopup', $M.toGetParam(param));
		}

		function openCustArsPopup(data) {
			if(data.real_hp_no == "") {
				alert("등록된 핸드폰 번호가 없습니다.");
				return;
			}

			var param = {
				hp_no : data.real_hp_no,
			}

			$M.goNextPage('/cust/cust0108p01', $M.toGetParam(param), {popupStatus : ''})
		}
		////////////////////////////////////////////////////////////////////////////////////
		////////////////  CTI 관련 메소드  ///////////////////
		////////////////////////////////////////////////////////////////////////////////////
		// cti 상담원정보
		var cti = {
			id : '',
			pwd : '',
			extNum : '',	// 내선번호
			statusCd : ''	// 상담원상태코드 (2:인대기, 3:후처리, 기타 나머지..)
		};

		// cti 전화요청 시 호출하는 api 생성 시 삭제예정
		var call_cust_info = {
			txt_CID : '',
			txt_CONNECTKEY : '',
			txt_ARSSVC_NM : '',
			txt_ARSGROUP_NM : '',
		}

		/**
		 * 상담원 목록 갱신
		 */
		function fnAgListRefresh(onlyOrgYn) {
			var agSelList = ['ag_id'];
			$M.goNextPageAjax(this_page + "/searchAgList", 'only_org_yn=' + onlyOrgYn, {method : 'get'},
					function(result) {
						if(result.success) {
							$.each(agSelList, function(){
								var selObj = $M.getComp(this);
								var selRow = this;

								selObj.options.length = 0;
								selObj.add(new Option("- 상담사 선택 -", ""));

								$.each(result.agList, function() {
									if(selRow == 'ag_id') {
										selObj.add(new Option(this.ag_info, this.ag_id));
									} else if(selRow == 'trans_ag_id') {
										// 호전환일때는 내선번호로 셋팅
										if( cti.id != this.ag_id ) {
											selObj.add(new Option(this.ag_info, this.ext_num));
										}
									}
								});
							});

						}
					}
			)
		}

		/**
		 * 그룹호 목록 갱신
		 */
		function fnGroupRefresh() {
			$M.goNextPageAjax(this_page + "/searchGroupList", '', {method : 'get'},
					function(result) {
						if(result.success) {
							var selObj = $M.getComp('trans_group_id');

							selObj.options.length = 0;
							selObj.add(new Option("- 호전환그룹 선택 -", ""));

							$.each(result.groupList, function() {
								selObj.add(new Option(this.ext_name, this.ext_num));
							});

						}
					}
			)
		}

		/**
		 * 자동으로 목록 갱신
		 */
		function fnAutoRefresh() {
			if($M.getValue('s_auto_refresh_yn') == 'Y') {
				// 날짜오늘
				$M.setValue('s_start_dt', '${inputParam.s_current_dt}');
				$M.setValue('s_end_dt', '${inputParam.s_current_dt}');

				// 상담부서셋팅
				var orgName = "${SecureUser.org_type eq 'CENTER' ? SecureUser.org_name : ''}";
				//$M.setValue('s_org_name', orgName);

				$M.setValue('s_cust_name', '');
				$M.setValue('s_hp_no', '');
				$M.setValue('s_mem_name', '');
				$M.setValue('s_call_gubun', '');
				$M.setValue('s_complete_yn', '');
				//$M.setValue('s_receive_yn', '');

				goSearch();
			}
		}

		function fnLogin() {
			if($M.getValue('ag_id') == '') {
				alert('CTI 아이디를 선택하세요.');
				return;
			}

			// 시간차를 두고 재검색
			$M.goNextPageAjax(this_page + "/getAg", 'ag_id=' + $M.getValue('ag_id'), {method : 'get'},
					function(result) {
						if(result.success) {
							cti.id = result.ag_id;
							cti.pwd = result.ag_passwd;
							cti.extNum = result.ext_num

							// 로그인 수행
							funCTI_Connect(result.softphone_url, cti.id, cti.pwd, cti.extNum);
						} else {
							$M.setValue('ag_id', '');
						}
					}
			)
		}

		function fnLogout() {
			if (confirm('CTI 로그아웃 하시겠습니까?')) {
				funCTI_DisConnect(cti.id, cti.pwd, cti.extNum);
			}
		}

		/**
		 * 로딩바제어 (동작안함..)
		 * @param show true:보이기, false:감추기
		 */
		function fnLoadingBar(show) {
			if(show) {
				top.$('#popup-bg-loading').show();
				top.$('#bowlG').show();
			} else {
				top.$('#popup-bg-loading').hide();
				top.$('#bowlG').hide();
			}
		}

		function initArs() {
			$('#div_login').show();
			$('#div_logout').hide();
		}

		function fnCalling(hpNo) {
			var prefix = "91"; // OB로 전화걸기 시 91
			var obtel = hpNo;
			var gkid = "";  //사용시 개발자와 협의 필요
			var obtype = "02";  //변경 불가

			if(obtel == ""){
				alert("전화번호를 확인하세요");
				return;
			}

			callingCheck = true;

			funCTI_MakeCall(prefix,obtel,gkid,obtype);
		}

		function fnCallReceive() {
			funCTI_TelOffhook();
		}

		function fnCallStop() {
			funCTI_TelDrop();
		}

		/**
		 * 호전환 대상자 선택
		 * @param agId
		 */
		function fnTransAg(agId) {


		}

		function fnTransTry() {
			console.log("trans_ext_num => " + $M.getValue('trans_ag_id'));
			if($M.getValue('trans_ag_id') == '') {
				alert('전환할 상담사를 선택하세요.')
				return;
			}
			funCTI_TransOBCall($M.getValue('trans_ag_id'));
		}

		function fnGroupTransTry() {
			console.log("trans_group_ext_num => " + $M.getValue('trans_group_id'));
			if($M.getValue('trans_group_id') == '') {
				alert('그룹 호전환 번호를 선택하세요.');
				return;
			}
			funCTI_TransOBCall_Blind($M.getValue('trans_group_id'));
		}

		function fnTransOK() {
			funCTI_TransOBCall_OK();
		}

		function fnTransCancel() {
			funCTI_TransOBCall_Cancel();
		}

		function fnChangeStatus() {
			var changeStatusCd = $M.getValue('change_status');
			if(changeStatusCd == '') {
				alert('변경할 상태를 선택하세요.');
				return;
			}

			// WAIT(2, 인대기), NO(전화불가), 3: 후처리
			var currentStatusCd = cti.statusCd == '2' ? 'WAIT' : 'NO';

			if(currentStatusCd == changeStatusCd) {
				alert('현재 상태와 변경하려고 하는 상태가 동일합니다.');
				return;
			}

			fnChangeStatusValue(changeStatusCd);

			//var ctiAgState = changeStatusCd == 'WAIT' ? '2' : '3';
			//funCTI_AgState(ctiAgState);
		}

		/**
		 * 자식창에서도 동일하게 사용하므로 공통으로 변경
		 * @param changeStatusCd
		 */
		function fnChangeStatusValue(changeStatusCd) {
			var ctiAgState = changeStatusCd == 'WAIT' ? '2' : '3';
			funCTI_AgState(ctiAgState);
		}

		function fnOpenPopup() {
			alert($M.getValue('cti_hp_no') + '번호로 오픈합니다.');

			var param = {
				hp_no : $M.getValue('cti_hp_no'),
			}

			$M.goNextPage('/cust/cust0108p01', $M.toGetParam(param), {popupStatus : ''})
		}

		function startCalling() {
			// 전화번호가 없으면 받기/끊기 비활성화
			if(call_cust_info.txt_CID != '') {
				$('#btn_cti_call_receive').attr('disabled', true);
				$('#btn_cti_call_stop').attr('disabled', false);
			} else {
				$('#btn_cti_call_receive').attr('disabled', true);
				$('#btn_cti_call_stop').attr('disabled', true);
			}

			// 호전환관련 활성화
			$('#btn_cti_group_trans_try').attr('disabled', false);
			$('#btn_cti_trans_try').attr('disabled', false);
			$('#btn_cti_trans_ok').attr('disabled', false);
			$('#btn_cti_trans_cancel').attr('disabled', false);

			console.log(" ------ 전화시작 -------")

			var param = {
				hp_no : call_cust_info.txt_CID,
				connect_key : call_cust_info.txt_CONNECTKEY,
				gubun_1 : call_cust_info.txt_ARSGROUP_NM,
				gubun_2 : call_cust_info.txt_ARSSVC_NM,
			}

			console.log(" 전화번호 : " + param.hp_no);

			// 수화기를 든 경우는 팝업이 열리지 않도록 수정(전화통화 전)
			if(param.hp_no == '') {
				return;
			}

			console.log(" ----- 전화시작 1 ------- ");

			if(callingCheck) {
				console.log(" ----- 전화시작 2 ------- ");

				// 전화걸기 상태에서 전화통화가 시작된 경우
				if(param.hp_no.length > 2) {
					param.hp_no = param.hp_no.substring(2);
				}

				console.log(" ----- 전화시작 3 ------- ");

				if(popupWin == null || popupWin.closed || popupWin.inputHpNo != param.hp_no) {
					console.log(" ----- 전화시작 4 ------- ");
					// ARS 상담관리가 이미 열려있지 않았다면
					$M.goNextPage('/cust/cust0108p01', $M.toGetParam(param), {popupStatus : ''})
				} else {
					console.log(" ----- 전화시작 5 ------- ");
					// ARS 상담관리가 이미 열려있다면 param으로 행추가
					var arsDate = $M.dateFormat(param.connect_key.substring(0, 14), 'yyyy-MM-dd HH:mm:ss');

					var row = {
						ars_date : arsDate
						, ars_seq : '0'
						, call_telnum : param.hp_no
						, send_no : param.hp_no
						, call_minute : ''
						, consult_text : ''
						, call_cticonkey : param.connect_key
						, call_gr_nm : ''
						, call_svc_nm : ''
						, org_name : ''
						, ars_mem_no : ''
						, ars_mem_name : ''
						, complete_yn : 'N'
						, cb_telnum : ''
						, cb_gkcid : ''
						, file_seq : '0'
						, rec_url : '0'
						, reg_id : 'SYSTEM'
						, paper_info : ''
					}

					popupWin.fnAddRows(row);
				}
			} else {
				console.log(" ----- 전화시작 6 ------- ");
				// 전화받기로 전화통화가 시작된 경우
				$M.goNextPage('/cust/cust0108p01', $M.toGetParam(param), {popupStatus : ''})
			}
		}
		//////////////////////////////////////////////////////
		//////// 하위는 CTI 업체에서 제공해주는 Method  Start /////
		//////////////////////////////////////////////////////
		function RT_NTSCTIOpen_EVT() {
			console.log("cti gw 접속 성공");
		}

		function RT_NTSCTIClose_EVT(evt) {
			console.log("cti gw 접속 종료 : " + evt.code);

			initArs();
		}

		function RT_NTSCTIError_EVT(evt) {
			console.log("cti gw error : " + evt.data);
			alert('소프트폰 로그인에 실패하였습니다.\n\n소프트폰을 실행하시고,\n다른 곳에서 로그인 했는지(중복허용안함) 확인해주세요.');
		}

		/* CTI 로그인 성공 */
		function RT_NTSCTILoginSUCC_EVT(txt_AGNM, txt_AGGROUP_CD, txt_AGGROUP_NM, txt_AG_TELNUM, txt_SPEC_NM, txt_RTN_CD) {
			var log = "RT_NTSCTILoginSUCC_EVT =>";
			log = log + "이름 : " + txt_AGNM + ",";
			log = log + "상담그룹코드 : " + txt_AGGROUP_CD + ",";
			log = log + "상담그룹이름 : " + txt_AGGROUP_NM + ",";
			log = log + "상담분배그룹이름 : " + txt_SPEC_NM + ",";
			log = log + "내선번호 : " + txt_AG_TELNUM + ",";
			log = log + "결과코드 : " + txt_RTN_CD + ",";

			console.log(log);

			var loginInfo = txt_AGNM+'('+txt_AG_TELNUM+')';
			$('#la_txt_AGNM').html(loginInfo);

			$('#div_login').hide();
			$('#div_logout').show();

			//fnAgListRefresh('N');
			fnGroupRefresh();
		}

		/* 로그인,로그아웃 실패 */
		function RT_NTSCTICOMFAIL_EVT(code, msg) {
			var log = "RT_NTSCTICOMFAIL_EVT=>";
			log = log + "cd  : " + code;
			log = log + "msg : " + msg;

			console.log(log);

			alert('CTI 로그아웃에 실패하였습니다.\n사유 : ' + msg);
		}

		/* CTI  로그아웃 성공 */
		function RT_NTSCTILogOutSUCC_EVT(txt_RTN_CD) {
			var log = "RT_NTSCTILogOutSUCC_EVT =>";
			log = log + "결과코드 : " + txt_RTN_CD + ",";

			console.log(log);

			cti = {
				id : '',
				pwd : '',
				extNum : '',	// 내선번호
				statusCd : ''	// 상담원상태코드 (2:인대기, 3:후처리, 기타 나머지..)
			};

			fnAgListRefresh('Y');
			$('#div_login').show();
			$('#div_logout').hide();
		}

		/*  전화걸기 , 전화끊기등 1차 결과 성공시   */
		function RT_NTSCTICOMSUCC_EVT(txt_rtnnm, txt_rtncd) {
			var log = "RT_NTSCTICOMSUCC_EVT =>";
			log = log + "EVENT명 : " + txt_rtnnm + ",";
			log = log + "EVENT결과 : " + txt_rtncd + ",";

			// 끊기
			if(txt_rtnnm == 'TELONOFF' && txt_rtncd == '0000') {
				$('#btn_cti_call_receive').attr('disabled', true);
				$('#btn_cti_call_stop').attr('disabled', true);
			}

			console.log(log);
		}

		/* 전화 통화 연결 되었을때  */
		function RT_NTSCTICONINFO_EVT(txt_CON_CALLER_ID, txt_CON_CALLCONNECT_KEY, txt_CON_CALLINOB, txt_CON_CALLTYPE) {
			var log = "RT_NTSCTICONINFO_EVT =>";
			log = log + "전화번호 : " + txt_CON_CALLER_ID + ",";
			log = log + "연결키 : " + txt_CON_CALLCONNECT_KEY + ",";
			log = log + "콜종류 : " + txt_CON_CALLINOB + ",";
			log = log + "콜구분 : " + txt_CON_CALLTYPE + ",";

			console.log(log);
			call_cust_info.txt_CID = txt_CON_CALLER_ID;
			call_cust_info.txt_CONNECTKEY = txt_CON_CALLCONNECT_KEY;

			setTimeout(startCalling, 100);
		}

		/* 전화 올때   */
		function RT_NTSCTIRINGINFO_EVT(txt_CID, txt_ARSGROUP_NM, txt_ARSSVC_NM, txt_WAITTIME, txt_DNIS_NM, txt_ARSCID, txt_ETC_ARS_1, txt_ETC_ARS_2, txt_ETC_ARS_3, txt_CONNECTKEY, txt_ENC_1, txt_ENC_2, txt_SP_GROUP_CODE,
									   txt_SP_SVC_CODE, txt_AG_DEGREE, txt_GK_ETC_INFO, txt_AG_TOTTIME, txt_CTI_DNIS_CD, txt_CTI_DNIS_NM, txt_RING_CALLTYPE, txt_RING_INOB, txt_RING_SPYN, txt_ETC_TEL
		) {
			var log = "RT_NTSCTIRINGINFO_EVT =>";
			log = log + "txt_CID : " + txt_CID + ",";
			log = log + "txt_ARSGROUP_NM : " + txt_ARSGROUP_NM + ",";
			log = log + "txt_ARSSVC_NM : " + txt_ARSSVC_NM + ",";
			log = log + "txt_WAITTIME : " + txt_WAITTIME + ",";
			log = log + "txt_DNIS_NM : " + txt_DNIS_NM + ",";
			log = log + "txt_ARSCID : " + txt_ARSCID + ",";
			log = log + "txt_ETC_ARS_1 : " + txt_ETC_ARS_1 + ",";
			log = log + "txt_ETC_ARS_2 : " + txt_ETC_ARS_2 + ",";
			log = log + "txt_ETC_ARS_3 : " + txt_ETC_ARS_3 + ",";
			log = log + "txt_CONNECTKEY : " + txt_CONNECTKEY + ",";
			log = log + "txt_ENC_1 : " + txt_ENC_1 + ",";
			log = log + "txt_ENC_2 : " + txt_ENC_2 + ",";
			log = log + "txt_SP_GROUP_CODE : " + txt_SP_GROUP_CODE + ",";
			log = log + "txt_SP_SVC_CODE : " + txt_SP_SVC_CODE + ",";
			log = log + "txt_AG_DEGREE : " + txt_AG_DEGREE + ",";
			log = log + "txt_GK_ETC_INFO : " + txt_GK_ETC_INFO + ",";
			log = log + "txt_AG_TOTTIME : " + txt_AG_TOTTIME + ",";
			log = log + "txt_CTI_DNIS_CD : " + txt_CTI_DNIS_CD + ",";
			log = log + "txt_CTI_DNIS_NM : " + txt_CTI_DNIS_NM + ",";
			log = log + "txt_RING_CALLTYPE : " + txt_RING_CALLTYPE + ",";
			log = log + "txt_RING_INOB : " + txt_RING_INOB + ",";
			log = log + "txt_RING_SPYN : " + txt_RING_SPYN + ",";
			log = log + "txt_ETC_TEL : " + txt_ETC_TEL + ",";

			console.log(log);

			// 전화가 걸려온 동시에 팝업창이 열려있다면 focus주고 확인시키기
			// if(popupWin != null && popupWin.closed == false && !callingFocusCheck) {
			// 	popupWin.blur();
			// 	setTimeout(popupWin.focus(), 200);
			// }
			callingFocusCheck = true;

			call_cust_info.txt_CID = txt_CID;
			call_cust_info.txt_CONNECTKEY = txt_CONNECTKEY;
			call_cust_info.txt_ARSGROUP_NM = txt_ARSGROUP_NM;
			call_cust_info.txt_ARSSVC_NM = txt_ARSSVC_NM;
			call_cust_info.txt_ETC_TEL = txt_ETC_TEL;		// 호전환시 호전환 from 내선번호들어있음(3205) , 일반전화시는 *)
			call_cust_info.txt_RING_CALLTYPE = txt_RING_CALLTYPE;	// 호전환시 : 상담원직접호전환:5, 일반전화시 : IVR-IB통화:9

			if(txt_RING_CALLTYPE.includes("전환")) {
				// 전화를 받은 상태 (전환 시에만 상담원 상태는 유지되면서 RING만 없어짐)
				startCalling();
				transCheck = true;
			}


			$M.goNextPageAjax(this_page + "/getCust", 'hp_no=' + txt_CID, {method : 'get'},
					function(result) {
						if(result.success) {
							// 전화정보활성화
							var locInfo = txt_ARSGROUP_NM;
							locInfo += txt_ARSSVC_NM != '' ? ' > ' + txt_ARSSVC_NM : '';
							$('#la_call_path').html(locInfo);
							$('#la_call_who').html(result.hp_no + ' ' + result.cust_name + '님');

							// 호전환일때 정보 보여짐
							var whoTypeInLine = txt_ETC_TEL != '*' && txt_ETC_TEL.length == 4 ? true : false;	// 내선유무
							var whoTypeStr = whoTypeInLine ? '내선(' + txt_ETC_TEL + ') 에서 호전환요청' : '일반전화' ;
							$('#la_call_who_type').html('('+whoTypeStr+')');

							$('#la_call_info').show();
							$('#la_call_status').hide();
						}
						// 고객정보 조회 상관없이 전화받기 활성화
						$('#btn_cti_call_receive').attr('disabled', false);
						$('#btn_cti_call_stop').attr('disabled', true);

						window.blur();
						setTimeout(window.focus(), 200);
					}
			)
		}

		/* 전화 할때   */
		function RT_NTSCTIDIALNFO_EVT(txt_CID) {
			var log = "RT_NTSCTIDIALNFO_EVT =>";
			log = log + "txt_CID : " + txt_CID + ",";

			callingCheck = true;

			// 팝업창에서 전화히므로 비활성화
			$('#btn_cti_call_receive').attr('disabled', true);
			$('#btn_cti_call_stop').attr('disabled', true);

			console.log(log);
		}

		/* 전화 종료   */
		function RT_NTSCTIDROPNFO_EVT(etc) {
			var log = "RT_NTSCTIDROPNFO_EVT =>";
			log = log + "etc : " + etc + ",";

			console.log(log);

			callingCheck = false;

			$('#la_call_info').hide();
			$('#la_call_status').show();

			$('#btn_cti_call_receive').attr('disabled', true);
			$('#btn_cti_call_stop').attr('disabled', true);

			// 호전환관련 비활성화
			$('#btn_cti_group_trans_try').attr('disabled', true);
			$('#btn_cti_trans_try').attr('disabled', true);
			$('#btn_cti_trans_ok').attr('disabled', true);
			$('#btn_cti_trans_cancel').attr('disabled', true);

			if(call_cust_info.txt_CID == '') {
				return;
			}

			call_cust_info.txt_CID = '';
			call_cust_info.txt_CONNECTKEY = '';
			call_cust_info.txt_ARSGROUP_NM = '';
			call_cust_info.txt_ARSSVC_NM = '';

			var syncParam = {
				start_dt : $M.getCurrentDate('yyyyMMdd'),
				call_end_yn : 'Y',
			}

			// 전화통화 종료 시 동기화 실행
			$M.goNextPageAjax("/cti_ars/syncCtiCallList", $M.toGetParam(syncParam), {method : 'post'},
					function(result) {
						if(result.success) {
						}
					}
			)
		}

		/* CTI 상태값 Recv - 1초에 한번씩 RECV : 상태변경,전화상태을 표시 */
		function RT_NTSCTICOMMINFO_EVT(txt_AGSTATE, txt_TELSTATE, txt_USER_USE_TIME, txt_USER_WAITCALLCNT, txt_SEND_TIME, txt_AGSTATE_CD, txt_CB_CNT, txt_ETC_CNT_1, txt_ETC_CNT_2, txt_ETC_CNT_3) {
			var log = "RT_NTSCTICOMMINFO_EVT =>";
			log = log + "상담원상태 : " + txt_AGSTATE + ",";
			log = log + "전화기상태 : " + txt_TELSTATE + ",";
			log = log + "사용시간 : " + txt_USER_USE_TIME + ",";
			log = log + "접속시간 : " + txt_SEND_TIME + ",";
			log = log + "상담원상태코드: " + txt_AGSTATE_CD + ",";
			log = log + "대기호 : " + txt_USER_WAITCALLCNT + ",";
			log = log + "콜백 : " + txt_CB_CNT + ",";
			log = log + "기타1 : " + txt_ETC_CNT_1 + ",";
			log = log + "기타2 : " + txt_ETC_CNT_2 + ",";
			log = log + "기타3 : " + txt_ETC_CNT_3 + ",";

			// console.log(log);

			var disTime = '';	//20230821 180341
			if(txt_SEND_TIME.length == 14) {
				disTime = txt_SEND_TIME.substring(8, 10) + ':' + txt_SEND_TIME.substring(10, 12) + ':' + txt_SEND_TIME.substring(12, 14);
			}

			$('#la_txt_SEND_TIME').html(disTime);
			$('#la_txt_USER_WAITCALLCNT').html(txt_USER_WAITCALLCNT);

			// 전화가 걸려온 동시에 팝업창이 열려있다면 focus주고 확인시키기
			if(txt_AGSTATE_CD == '8' && !callingCheck) {
				if(popupWin != null && popupWin.closed == false && !callingFocusCheck) {
					popupWin.blur();
					setTimeout(popupWin.focus(), 200);
				}
				callingFocusCheck = true;
				if(txt_TELSTATE != "RING" && !transCheck) {
					// 전화를 받은 상태 (전환 시에만 상담원 상태는 유지되면서 RING만 없어짐)
					startCalling();
					transCheck = true;
				}
			} else if(txt_AGSTATE_CD != '8') {
				callingFocusCheck = false;
				transCheck = false;
			}

			// 상담원 상태 및 정보 변경
			cti.statusCd = txt_AGSTATE_CD;

			$('#la_call_status').html(cti.statusCd == '2' ? '전화수신 대기 중입니다.' : '전화수신 불가 입니다.');
			if(cti.statusCd == '2') {
				$('#la_txt_AGSTATE_wait').show();
				$('#la_txt_AGSTATE_wait').html(txt_AGSTATE + '(' + txt_USER_USE_TIME + ')');
				$('#la_txt_AGSTATE_no').hide();
				$('#div_logout').removeClass('ars-bg-disabled');
				$('#div_logout').addClass('ars-bg');

				// 전화받기/끊기 비활성화
				$('#btn_cti_call_receive').attr('disabled', true);
				$('#btn_cti_call_stop').attr('disabled', true);

			} else {
				$('#la_txt_AGSTATE_wait').hide();
				$('#la_txt_AGSTATE_no').show();
				$('#la_txt_AGSTATE_no').html(txt_AGSTATE + '(' + txt_USER_USE_TIME + ')');
				$('#div_logout').removeClass('ars-bg');
				$('#div_logout').addClass('ars-bg-disabled');
			}
		}
		//////////////////////////////////////////////////////
		//////// 여기까지 CTI 업체에서 제공해주는 Method End  /////
		//////////////////////////////////////////////////////

		// 전월통계 팝업 호출
		function goPreMonthStats() {
			$M.goNextPage('/cust/cust0108p02', '', {popupStatus : ''})
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 메인 타이틀 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /메인 타이틀 -->
		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="title-wrap">
				<h4 class="primary">ARS관리</h4>
			</div>
			<!-- 기본 -->
			<!-- CTI 로그인전 -->
			<div id="div_login" class="ars-bg login">
				<strong class="text-primary">CTI로그인</strong>
				<select id="ag_id" name="ag_id"  class="form-control" style="width: 300px;">
					<option value="">- 상담사 선택 -</option>
					<c:forEach items="${agList}" var="item">
						<option value="${item.ag_id}">${item.ag_info}</option>
					</c:forEach>
				</select>
				<button type="button" class="btn btn-default mr3" onclick="javascript:fnAgListRefresh('Y');"><i class="material-iconsrefresh text-default"></i>새로고침</button>
				<button id="btn_cti_login" class="btn btn-success btn-md" type="button" onclick="javascript:fnLogin();">CTI 로그인</button>
			</div>
			<!-- /CTI로그인 전 -->
			<!-- CTI 로그인후 -->
			<div id="div_logout" style="display: none;" class="ars-bg call">
				<div class="col justify-content-between" style="flex-basis: 246px;">
					<div class="left">
						<div>
							<span id="la_txt_AGNM">장현석</span>님
							<span id="la_txt_AGSTATE_wait" class="ver-line text-primary">전화대기</span>
							<span id="la_txt_AGSTATE_no" style="display: none;" class="ver-line text-secondary">전화불가</span>
						</div>
					</div>
					<div class="right">
						<button type="button"  id="btn_cti_logout" class="btn btn-secondary btn-md" type="button" onclick="javascript:fnLogout();">CTI 로그아웃</button>
					</div>
				</div>
				<div class="col justify-content-between" style="flex-basis: 390px;">
					<div class="left">
						<div id="la_call_info" style="display: none;">
							<div id="la_call_path">정비상담 &#62; 출장요청</div>
							<%--						<div id="la_call_" class="text-default">일산센터에서 전환시도 02-0000-0000</div>--%>
							<strong id="la_call_who">02-0000-0000 홍길동님</strong>
							&nbsp;<strong id="la_call_who_type" style="color: red"></strong>
						</div>
						<div id="la_call_status" class="text-primary">전화상태 체크 중입니다.</div>
					</div>
					<div class="right">
						<button type="button" class="btn btn-primary btn-md" id="btn_cti_call_receive" onclick="javascript:fnCallReceive();" disabled>전화받기</button>
						<button type="button" class="btn btn-warning btn-md" id="btn_cti_call_stop" onclick="javascript:fnCallStop();" disabled>전화끊기</button>
					</div>
				</div>
				<div class="col flex-column align-items-start justify-content-center" style="flex-basis: 326px;"><div>
					현재시간 : <span id="la_txt_SEND_TIME">12:30:00</span>
					<span class="ver-line">&nbsp;</span>
					대기호 <span id="la_txt_USER_WAITCALLCNT">0</span>건
				</div>
					<div class="mt6 d-flex">
						<select id="trans_group_id" name="trans_group_id" style="width: 150px;" class="form-control mr5" onchange="javascript:fnTransAg(this.value);">
							<option value="">- 호전환그룹 선택 -</option>
						</select>
						<button type="button" class="btn btn-default mr3" onclick="javascript:fnGroupRefresh();"><i class="material-iconsrefresh text-default"></i>새로고침</button>
						<button id="btn_cti_group_trans_try" type="button" class="btn btn-outline-primary mr3" onclick="javascript:fnGroupTransTry();" disabled>전환</button>
						<!-- 그룹호전환으로 변경
						<button id="btn_cti_trans_try" type="button" class="btn btn-outline-primary mr3" onclick="javascript:fnTransTry();" disabled>전환시도</button>
						<button id="btn_cti_trans_ok" type="button" class="btn btn-outline-success mr3" onclick="javascript:fnTransOK();" disabled>전환완료</button>
						<button id="btn_cti_trans_cancel" type="button" class="btn btn-outline-secondary" onclick="javascript:fnTransCancel();" disabled>전환취소</button>
						-->
					</div>
				</div>
				<div class="col" style="flex-basis: 207px;">
					<div class="mr5">상태설정</div>
					<select  id="change_status" name="change_status" class="form-control mr5" style="flex-basis: 100px;">
						<option value="">- 상태선택 -</option>
						<option value="WAIT">전화대기</option>
						<option value="NO">전화불가</option>
					</select>
					<button id="btn_change_status" type="button" class="btn btn-outline-primary" onclick="javascript:fnChangeStatus();">변경</button>
				</div>
			</div>
			<!-- /CTI 로그인후 -->
			<div class="search-wrap mt10">
				<table class="table">
					<colgroup>
						<col width="70px">
						<col width="100px">
						<col width="70px">
						<col width="100px">
						<col width="80x">
						<col width="100px">
						<col width="70px">
						<col width="70px">
						<col width="30px">
						<col width="70px">
						<col width="">
					</colgroup>
					<tbody>
					<tr>
						<th>수신일자</th>
						<td colspan="3">
							<div class="form-row inline-pd widthfix">
								<div class="col width115px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" alt="시작일자" value="">
									</div>
								</div>
								<div class="col width16px text-center">~</div>
								<div class="col width110px">
									<div class="input-group">
										<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd" value="" alt="종료일자">
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
						<th>현재상담부서</th>
						<td>
							<select class="form-control" name="s_org_name" id="s_org_name">
								<option value="">- 전체 -</option>
<%--								<option value="본사센터">본사센터</option>--%>
<%--								<option value="부품관리(평택3)">부품영업부</option>--%>
<%--								<option value="서비스관리(평택2)">서비스관리</option>--%>
								<c:forEach items="${arsOrgList}" var="item">
									<option value="${item.org_name}" ${SecureUser.org_name eq item.org_name ? 'selected' : ''}>${item.org_name}</option>
								</c:forEach>
							</select>
						</td>
						<th>고객명</th>
						<td colspan="2">
							<div>
								<input type="text" id="s_cust_name" name="s_cust_name" class="form-control" style="width: 100px; display: inline-block;">
							</div>
						</td>
						<th>전화번호</th>
						<td>
							<div>
								<input type="text" id="s_hp_no" name="s_hp_no" class="form-control" style="width: 100px; display: inline-block;">
							</div>
						</td>
					</tr>

					<tr>
						<th>상담직원</th>
						<td>
							<input type="text" id="s_mem_name" name="s_mem_name" class="form-control" style="width: 100px; display: inline-block;">
						</td>
						<th>수신상태</th>
						<td>
							<select class="form-control" id="s_call_gubun" name="s_call_gubun">
								<option value="">- 전체 -</option>
								<option value="수신완료">수신완료</option>
								<option value="미 수신">미 수신</option>
								<option value="절단호">절단호</option>
								<option value="포기호">포기호</option>
								<option value="콜백요청">콜백요청</option>
								<option value="발신">발신</option>
							</select>
						</td>
						<th>처리구분</th>
						<td>
							<select class="form-control" id="s_complete_yn" name="s_complete_yn">
								<option value="">- 전체 -</option>
								<option value="Y">처리완료</option>
								<option value="N">미 처리</option>
							</select>
						</td>
						<td class="pl10" colspan="2">
							<div class="form-check form-check-inline">
								<input class="form-check-input" type="checkbox" id="s_receive_yn" name="s_receive_yn" value="Y">
								<label class="form-check-label" for="s_receive_yn">절단/포기호 제외</label>
							</div>
						</td>
						<td colspan="3">
							<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:goSearch()"  >조회</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /기본 -->
			<!-- 그리드 타이틀, 컨트롤 영역 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<div class="btn-group">
					<div class="right">
						<c:if test="${page.fnc.F05083_002 eq 'Y'}">
							<div class="table-attfile" style="display: inline-block; margin-rightt: 5px;">
								<button type="button" class="btn btn btn-danger mr5"  onclick="javascript:goPreMonthStats();">전월통계</button>
							</div>
						</c:if>
						<div class="form-check form-check-inline">
							<input class="form-check-input" type="checkbox" id="s_auto_refresh_yn" name="s_auto_refresh_yn"  checked="checked" value="Y" />
							<label class="form-check-input" for="s_auto_refresh_yn" style="color: #ff7f00;">목록자동갱신</label>
						</div>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
						<%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<%--						임시팝업 ||--%>
						<%--						<input type="text" id="cti_hp_no" name="cti_hp_no" class="form-control" style="width: 150px; display: inline-block;">--%>
						<%--						<button type="button" class="btn btn-important" style="width: 50px;"  onclick="javascript:fnOpenPopup()"  >팝업열기</button>--%>
						<div class="form-check form-check-inline" style="margin-left : 5px;">
							<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
								<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
								<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
							</c:if>
						</div>
						<span id="receive_cnt">수신완료 0</span>
						<span class="ver-line" id="cut_cnt">절단호 0</span>
						<span class="ver-line" id="giveup_cnt">포기호 0</span>
						<span class="ver-line mr10" id="callback_cnt">콜백요청 0</span>
						<%--						<button type="button" class="btn btn-default mr3" onclick="javascript:fnRefresh();"><i class="material-iconsrefresh text-default"></i>새로고침</button>--%>
						<button type="button" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
					</div>
				</div>
			</div>
			<!-- /그리드 타이틀, 컨트롤 영역 -->
			<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="left">
					<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
				</div>
				<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
	</div>
	</div>
	<!-- /contents 전체 영역 -->
	</div>
</form>
<script>
	$(document).ready(function() {
		goSearch();
	});
</script>
</body>
</html>