<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 정보수정 > null > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-05-15 18:41:52
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var defaultImg ="/static/img/icon-user.png";
		var auiGridBom;
		
		function fnDownloadExcel() {
			// 엑셀 내보내기 속성
			  var exportProps = {
					  exceptColumnFields : ["use_yn"]
			  };
			  fnExportExcel(auiGridBom, "자격사항", exportProps);
		}

		$(document).ready(function() {
			
			// AUIGrid 생성
			createBomAUIGrid();
			
			fnSetInitBtn();	  // 호출페이지에 따른 버튼세팅
			fnSetOrgAuthCd(); // 부서권한 세팅
			fnSetJobAuthCd(); // 업무권한 세팅
			
			// 기본 프로필 이미지 크기 세팅
			if($("#profileImage").attr("src") ==  defaultImg ) {
				$("#profileImage").width(150);
			};
			
			// 퇴직일, 입사일자 버튼 비활성화
			$("#retireField").children("button").addClass("btn-cancel");
			$("#retireField").children("button").attr("disabled", true);
			$("#ipsaDtField").children("button").addClass("btn-cancel");
			$("#ipsaDtField").children("button").attr("disabled", true);
	
			//퇴직여부 확인
			if($M.getValue("work_status_cd") == "04") {
				fnRetireYn(true);
			}
			else {
				fnRetireYn(false);
			};
			
			$("#work_status_cd").change(function() {
				if($M.getValue("work_status_cd") == "04") {
					fnRetireYn(true);
				} else {
					fnRetireYn(false);
				};
			});
			// END 퇴직여부 확인
			
			// 프로필 이미지 X버튼 클릭 시 이벤트 
			$("#fileRemoveBtn").on("click",function(e){
				fnRemoveFile();
			});
			
			// 핸드폰번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
			$("#hp_no").on("propertychange change keyup paste input", function() {
				console.log($M.getValue("lastchk_hp_no") + " / " + $M.getValue("hp_no"));
				if ($M.getValue("lastchk_hp_no") == this.value) {
					$M.setValue("hp_no_chk", "Y");					
					$("#btn_hp_no_chk").prop("disabled", true);
				} else {
					$M.setValue("hp_no_chk", "N");
					$("#btn_hp_no_chk").prop("disabled", false);
				};
			});
						
			// 주민등록번호 중복체크 완료 후 번호 변경 시 중복체크 다시 실행
			// - Q&A 14315 : 주민등록 번호 사라지는 문제
			// $("#resi_no1, #resi_no2").on("propertychange change keyup paste input", function() {
			// 	var resi_no1 = $M.nvl($M.getValue("resi_no1"), "");
			// 	var resi_no2 = $M.nvl($M.getValue("resi_no2"), "");
			// 	var resi_no  = resi_no1 + resi_no2;
			//
			// 	// 주민등록번호 입력 안할 시 중복체크X
			// 	if(resi_no == "") {
			// 		$M.setValue("resi_no_chk", "Y");
			// 		$("#btn_resi_no_chk").prop("disabled", true);
			// 		return;
			// 	};
			//
			// 	if ($M.getValue("lastChk_resi_no") == resi_no) {
			// 		$M.setValue("resi_no_chk", "Y");
			// 		$("#btn_resi_no_chk").prop("disabled", true);
			// 	} else {
			// 		$M.setValue("resi_no_chk", "N");
			// 		$("#btn_resi_no_chk").prop("disabled", false);
			// 	};
			// });

		});
		
		
		// 부서권한 세팅
		function fnSetOrgAuthCd() {
			var orgAuthCd 		= "${bean.org_auth_cd}";
			var orgAuthName 	= "${bean.org_auth_name}";
			var orgAuthNameMulti	= "";

			if(orgAuthCd.indexOf("#") != -1) {
				// 다중
				orgAuthNameMulti = orgAuthName.split("#");
				$M.setValue("org_auth_cd", orgAuthCd);
				$M.setValue("org_auth_name", orgAuthNameMulti);
			} else {
				// 단일
				$M.setValue("org_auth_cd", orgAuthCd);
				$M.setValue("org_auth_name", orgAuthName);
			};
			
			
		}
		
		// 버튼 세팅 비상연락망에서 호출시 수정불가
		function fnSetInitBtn() {
			var searchType = "${inputParam.search_type}";
			if(searchType == 'P') {
				$('#_goSave').hide();
				$('#fileAddBtn').hide();
				$('#fileRemoveBtn').hide();
				$('#_fnAdd').hide();
				$('#input').prop('readonly', true);
				$('#findAddress').attr('disabled', true);
				
			};
		
		}
		
		
		// 업무권한 세팅
		function fnSetJobAuthCd() {
			var jobAuthCd 		= "${bean.job_auth_cd}";
			var jobAuthName 	= "${bean.job_auth_name}";
			var jobAuthNameMulti	= "";
			
			if(jobAuthCd.indexOf("#") != -1) {
				// 다중
				jobAuthNameMulti = jobAuthName.split('#');
				$M.setValue("job_auth_cd", jobAuthCd);
				$M.setValue("job_auth_name", jobAuthNameMulti);
			} else {
				// 단일
				$M.setValue("job_auth_cd", jobAuthCd);
				$M.setValue("job_auth_name", jobAuthName);
			};
		}

		
		// 재직구분 선택 시 이벤트
		function fnRetireYn(flag) {
			
			if(flag) {
				$("#retire_dt").attr("readonly", false);						// 퇴직일 입력가능
				$("#retireField").children("button").attr('disabled', false);	// 퇴직일 달력 사용가능
				$("#retire_dt").attr("required", true);							// 퇴직일 필수	
				$("#cert_company_opinion").attr("readonly", false);				// 퇴직 시 회사의견 입력가능				
			} else {
				$("#retire_dt").attr("readonly", true);							// 퇴직일 입력불가
				$("#retireField").children("button").attr('disabled', true);	// 퇴직일 달력 사용불가
				$("#retire_dt").attr("required", false);						// 퇴직일 필수X
				$("#cert_company_opinion").attr("readonly", true);				// 퇴직 시 회사의견 입력불가
	
				$M.setValue("retire_dt", "");									// 퇴직일 초기화
				$M.setValue("cert_company_opinion", "");						// 퇴직 시 회사의견 초기화					
			};	
		}	
		
		// 주소값 세팅
		function fnSetAddress(data) {
			$M.setValue("home_post_no", data.zipNo);
			$M.setValue("home_addr1", data.roadAddrPart1);
			$M.setValue("home_addr2", data.addrDetail);
		}
		
		// 프로필 이미지 삭제 
		function fnRemoveFile(){
			$("#profile").remove();
			$("#profileImage").attr("src", defaultImg).width(150);
			$M.setValue("pic_file_seq","0");			
		}
		
		// 핸드폰번호 중복체크
		function goHpNoCheck() {
			var hpNoCheck = $M.nvl($M.getValue("hp_no"), "");
	
			if(hpNoCheck == "") {
				alert("핸드폰번호를 입력해주세요"); 
				return;	
			};
			

			if (hpNoCheck != "Y" ) {
				$M.goNextPageAjax(this_page + "/hpNoCheck/" + hpNoCheck, "", {method : "get"},
					function(result) {
			    		if(result.success) {
			    			$M.setValue("hp_no_chk", "Y");
			    			$M.setValue("lastchk_hp_no",$M.getValue("hp_no"));
			    			$("#btn_hp_no_chk").prop("disabled", true);
						} else {
							$M.setValue("hp_no_chk", "N");
							$("#btn_hp_no_chk").prop("disabled", false);
			    		};
					}
				);			
			} else {
				alert("사용가능한 핸드폰번호 입니다");
			};	
		}
		
		// 프로필 사진 등록 시 마우스(onmouseover) 삭제버튼 show
		function fnDelBtnShow() {	
			if($("#profileImage").attr("src") != defaultImg ) {
				$(".profilephoto-delete").show();
			}
		}
		
		// 마우스(onmouseout) 삭제버튼 hide
		function fnDelBtnHide() {
			$(".profilephoto-delete").hide();
		}
		
		// 파일 업로드
		function goUploadImg() {
			var param = {
				upload_type	: "MEM",
				file_type : "img",
				max_size : 1024,
				max_height : 200,
				max_width : 200,
			};
			openFileUploadPanel("fnSetImage", $M.toGetParam(param));
		}
		
		// 파일업로드 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result !== null && result.file_seq !== null) {
				$M.setValue("pic_file_seq",result.file_seq);				
			 	$('#profileImage').attr("src", "/file/" + result.file_seq + '').width(188);			  		
			};
		}
		
		// 주민등록번호 체크
		// - Q&A 14315 : 주민등록 번호 사라지는 문제
		// function goResiNoCheck() {
		//
		// 	var resi_no1 = $M.nvl($M.getValue("resi_no1"), "");
		// 	var resi_no2 = $M.nvl($M.getValue("resi_no2"), "");
		// 	var resi_no  = resi_no1 + resi_no2;
		//
		// 	var param = {
	 	// 		"resi_no" 	: resi_no,
		// 	};
		//
		// 	$M.goNextPageAjax(this_page + "/resiNoCheck/", "", {method : "post"},
		// 		function(result) {
		//     		if(result.success) {
		//     			$M.setValue("lastChk_resi_no", resi_no);
		//     			$M.setValue("resi_no_chk", "Y");
		//     			$("#btn_resi_no_chk").prop("disabled", true);
		// 			} else {
		//     			$M.setValue("resi_no_chk", "N");
		//     			$("#btn_resi_no_chk").prop("disabled", false);
		//     		};
		// 		}
		// 	);
		//
		// }
		
		
		// 자격사항 행 추가
		function fnAdd() {
			// 그리드 필수값 체크
			if(fnCheckLicGridEmpty(auiGridBom)) {
	    		var item = new Object();
	    		item.license_seq_no = -1;
	    		item.license_dt = "";
	    		item.license_kind = "";
	    		item.content = "";
	    		item.license_biz_name = "";
	    		item.license_no = "";
				item.origin_file_name = "";
				item.license_file_seq = 0;
				AUIGrid.addRow(auiGridBom, item, "first");
			};
		}
		
		
		// 자격사항 그리드 필수값 체크
		function fnCheckLicGridEmpty() {
			return AUIGrid.validateGridData(auiGridBom, ["content"], "필수 항목은 반드시 값을 입력해야합니다.");
		}
		
		
		// 저장
		function goSave() {

			// - Q&A 14315 : 주민등록 번호 사라지는 문제
			// var sResi_No = $M.getValue("resi_no1") + $M.getValue("resi_no2");
			// $M.setValue("resi_no", sResi_No);
		  	// validation check
	     	if($M.validation(document.main_form) === false) {
	     		return;
	     	};

	     	var frm = $M.toValueForm(document.main_form);

			// - Q&A 14315 : 주민등록 번호 사라지는 문제
			// if(sResi_No != "" && $M.getValue("resi_no_chk") == "N") {
			// 	alert("주민등록번호 중복검사를 진행해주세요");
			// 	return;
			// };
			
			if($M.getValue("hp_no_chk") == "N") {
				alert("핸드폰 번호 중복검사를 진행해주세요"); 
				return;
			};
			
			if (fnCheckLicGridEmpty(auiGridBom) === false) {
				alert("필수 항목은 반드시 값을 입력해야합니다.");
				return false;
			};
			
			// 그리드 데이터 저장
			var rowCount 	= AUIGrid.getRowCount(auiGridBom);
			// 자격사항 변경 데이터 
			var gridForm = fnChangeGridDataToForm(auiGridBom);
			
			// grid form 안에 frm 카피
			$M.copyForm(gridForm, frm);

			$M.goNextPageAjaxSave(this_page + "/modify", gridForm, {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}
		
		
		//그리드생성
		function createBomAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				fillColumnSizeMode : false,
				showRowNumColumn: true,
				showStateColumn : true,
				editable : true,
			};
			var columnLayout = [
				{
					dataField : "license_seq_no",
					visible : false
				},
				{
					headerText : "일자", 
					dataField : "license_dt",
					dataType : "date",   
					width : "100",
					minWidth : "90",
					style : "aui-center",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						onlyCalendar : false, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						maxlength : 8,
						onlyNumeric : true, // 숫자만
						validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							if(newValue == "") {
								// 날짜 지울 시 검사X
								return;
							};
							return fnCheckDate(oldValue, newValue, rowItem);
						},
						showEditorBtnOver : true
					},
				},
				{ 
					headerText : "자격구분", 
					dataField : "license_kind",
					editRenderer : {
				    	type : "InputEditRenderer",
				      	maxlength : 10,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					width : "105",
					minWidth : "45",
					style : "aui-center"
				},
				{ 
					headerText : "자격내용", 
					dataField : "content", 
					editRenderer : {
				    	type : "InputEditRenderer",
				      	maxlength : 50,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					style : "aui-left",
				},
				{ 
					headerText : "자격근거(기관)", 
					dataField : "license_biz_name", 
					editRenderer : {
				    	type : "InputEditRenderer",
				      	maxlength : 10,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					style : "aui-center",
				},
				{ 
					headerText : "자격번호", 
					dataField : "license_no", 
					editRenderer : {
				    	type : "InputEditRenderer",
				      	maxlength : 20,
				      	// 에디팅 유효성 검사
				      	validator : AUIGrid.commonValidator
					},
					style : "aui-center",
				},
				{
					headerText: "자격증",
					dataField: "origin_file_name",
					width : "100",
					minWidth : "90",
					editable: false,
					renderer : { // HTML 템플릿 렌더러 사용
						type : "TemplateRenderer"
					},
					labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
						if(item.license_file_seq == 0) {
							return '<button type="button" class="btn btn-default" style="width: 90%" onclick="javascript:goUploadImg(' + rowIndex + ');">이미지등록</button>';
						} else {
							var template = '<div>' + '<span style="color:black; cursor: pointer; text-decoration: underline;" onclick="javascript:fnPreview(' + item.license_file_seq + ');">' + value + '</span>' + '</div>';
							return template;
						}
					}
				},
				{
					headerText: "자격증이미지",
					dataField: "license_file_seq",
					visible: false,
				},
				{
					headerText : "삭제",
					dataField : "use_yn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridBom);
							if (isRemoved === false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);
							} else {
								AUIGrid.restoreSoftRows(auiGridBom, "selectedIndex");
							};
						}
					},
					width : "45",
					minWidth : "45",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return "삭제"
					},
					style : "aui-center",
					editable : false
				}
			];
	
			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			AUIGrid.setGridData(auiGridBom, memLicListJson);
			$("#auiGridBom").resize();
		}
		
		//팝업 닫기
		function fnClose() {
			window.close(); 
		}
		
		// 경조금지급신청서 출력
		function goPrint() {
			openReportPanel('acnt/acnt0601p01_01.crf','s_mem_no=' + '${inputParam.s_mem_no}');
		}
		
		// 라인계정연동 인증하기
		function goAuthAccount() {
 			var param = {
 				'pop_check_yn' : 'N',
 				'redirect_uri' : '/auth/line'
			};
			
 			var poppupOption = "width=550, height=450, top=0, left=0, resizable=no, scrollbars=no, location=no";
 			$M.goNextPage('/auth/goLogin', $M.toGetParam(param), {popupStatus : poppupOption});
		}
		
		// 라인계정연동 인증삭제
		function goRemoveAuthAccount() {
			if($M.getValue("mem_no") == "") {
				alert("직원번호가 없습니다."); 
				return false;
			};
			
			var param = {
					"mem_no" : $M.getValue("mem_no")
			}

			var msg = "라인계정 인증을 삭제하시겠습니까?";
			$M.goNextPageAjaxMsg(msg, this_page + "/authRemove", $M.toGetParam(param), {method : "POST"},
				function(result) {
		    		if(result.success) {
		    			location.reload();
					}
				}
			);
		}

		// 인사고과이동
		function goReferDetailPopup() {
			$M.goNextPage("/comm/comm0116p01", null, {popupStatus: ""});

			<%--var param = {--%>
			<%--		"s_mem_no": $M.getValue("mem_no"),--%>
			<%--		"s_grade_cd": "${bean.grade_cd}",--%>
			<%--		"s_org_code": "${bean.org_code}",--%>
			<%--		"show_all": "N",--%>
			<%--};--%>
			<%--var popupOption = "scrollbars=yes, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1600, height=800, left=0, top=0";--%>
			<%--$M.goNextPage("/acnt/acnt0601p01", $M.toGetParam(param), {popupStatus: popupOption, method: "post"});--%>
		}
		
		// 파일 업로드
		function goUploadImg(rowIndex) {
			var param = {
				upload_type: "MEM",
				file_type: "img",
				max_size: 1024,
				max_height: 200,
				max_width: 200,
			};

			if (rowIndex != undefined) {
				$M.setValue("license_row_index", rowIndex);
				openFileUploadPanel("fnSetLicenseImage", $M.toGetParam(param));
			} else {
				openFileUploadPanel("fnSetImage", $M.toGetParam(param));
			}
		}

		// 파일업로드 팝업창에서 받아온 값
		function fnSetImage(result) {
			if (result !== null && result.file_seq !== null) {
				$M.setValue("pic_file_seq", result.file_seq);
				$("#profileImage").attr("src", "/file/" + result.file_seq + "").width(188);
			}
		}

		// 자격사항 이미지 값 Setting
		function fnSetLicenseImage(result) {
			if (result !== null && result.file_seq !== null) {
				AUIGrid.updateRow(auiGridBom, {license_file_seq : result.file_seq}, $M.getValue("license_row_index"));
				AUIGrid.updateRow(auiGridBom, {origin_file_name : result.file_name}, $M.getValue("license_row_index"));
			}
		}

		function fnPreview(fileSeq) {
			var params = {
				file_seq : fileSeq
			};
			var popupOption = "";
			$M.goNextPage('/comp/comp0709', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
	</script>
</head>
<body  class="bg-white">
	<form id="main_form" name="main_form">

		<input type="hidden" id="mem_no" name="mem_no" value="${bean.mem_no}" />
		<input type="hidden" id="access_token" name="access_token" value="${bean.access_token}" />
		<input type="hidden" id="refresh_token" name="refresh_token" value="${bean.refresh_token}" />
<%--		<input type="hidden" id="resi_no" 			name="resi_no"  			value="">--%>
		<input type="hidden" id="lastchk_hp_no" 	value="${fn:replace(bean.hp_no, '-', '')}"		name="lastchk_hp_no" 	  >
<%--		<input type="hidden" id="lastchk_resi_no" 	value="${bean.resi_no}" 	name="lastchk_resi_no" 	 >--%>
		<input type="hidden" id="emp_id_chk" 		name="emp_id_chk" 			value="Y" >
		<input type="hidden" id="hp_no_chk" 		name="hp_no_chk" 			value="Y" >
<%--		<input type="hidden" id="resi_no_chk" 		name="resi_no_chk" 			value="Y" >	--%>
		<input type="hidden" id="pic_file_seq" 		name="pic_file_seq" 		value="${bean.pic_file_seq}" >
		<input type="hidden" id="upload_type"		name="upload_type"  		value="${inputParam.upload_type }"/>
		<div class="popup-wrap width-100per">
			<div class="main-title">
	            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
	        </div>
				<!-- contents 전체 영역 -->
				<div class="content-wrap">
					<div class="btn-group">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
						</div>				
					</div>
					<div class="">
					<!-- 메인 타이틀 -->
						
						<!-- /메인 타이틀 -->
						<div class="contents">	
							
							<!-- 폼테이블 -->					
							<div>
								<!-- 크롬 비번 자동완성 방지를 위한 input -->
							    <input type="password" style="display: block; width:0px; height:0px; border: 0;">
							    <input type="text" 	   style="display: block; width:0px; height:0px; border: 0;" name="__id">
								<table class="table-border mt5">
									<colgroup>
										<col width="100px">
										<col width="200px">
										<col width="100px">
										<col width="">
									</colgroup>
									<tbody>
										<tr>
											<th rowspan="7" class="text-center">										
												<div class="mb20">
													프로필 사진
												</div>
												<div class="form-row inline-pd">
													<div class="col-12 ">
														<button type="button" id="fileAddBtn" class="btn btn-primary-gra"  onclick="javascript:goUploadImg()"  style="width: 100%;">사진 업로드</button>
													</div>	
													<div id="fileDiv">
													</div>
												</div>	
											</th>									
											<td rowspan="7" class="text-center">
											
												<div class="profilephoto-item"  onmouseover="javascript:fnDelBtnShow();" onmouseout="javascript:fnDelBtnHide();">
													<img id="profileImage" src="/file/${bean.pic_file_seq}" alt="프로필 사진" class="icon-profilephoto" style="width:150px;"/>
														<div class="profilephoto-delete" style="display:none;">
															<button type="button" id="fileRemoveBtn" class="btn btn-icon-md text-light"><i class="material-iconsclose font-16"></i></button>
														</div>							
												</div>
											</td>
											<th class="text-right essential-item">직원명(한글)</th>
											<td>
												${bean.kor_name}
											</td>	
											<%-- <th class="text-right">직원명(한자)</th>
											<td>
												<input type="text" class="form-control width120px" value="${bean.chn_name}" id="chn_name" name="chn_name" datatype="string" maxlength="10" alt="직원명(한자)">
											</td> --%>	
											<%-- <th class="text-right">아이디</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width120px">
														<input type="text" class="form-control" value="${bean.web_id}" id="web_id"  name="web_id" required="required" alt="아이디" minlength="2" maxlength="30" disabled="disabled">
													</div>
												</div>										
											</td> --%>
										</tr>
										<tr>
											<%-- <th class="text-right">주민등록번호</th>
											<td> 
												<div class="form-row inline-pd widthfix">
													<div class="col width70px">
														<input type="text" id="resi_no1" name="resi_no1" class="form-control" minlength="6" maxlength="6" value="${fn:substring(bean.resi_no, 0, 6)}" datatype="int" onkeyup="if(this.value.length == 6) main_form.resi_no2.focus();" alt="주민번호 앞자리">
													</div>
													<div class="col width16px text-center">-</div>
													<div class="col width70px">
														<input type="password" id="resi_no2" name="resi_no2" class="form-control" minlength="7" maxlength="7" value="${fn:substring(bean.resi_no, 6, 13)}" datatype="int"  alt="주민번호 뒷자리">
													</div>
			
													<div class="col width60px">
														<button type="button" id="btn_resi_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goResiNoCheck();" disabled="disabled">중복확인</button>
													</div>
												</div>
											</td> --%>		
											<%-- <th class="text-right essential-item">생년월일</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width120px">
														<div class="input-group">
															<input type="text" id="birth_dt" name="birth_dt" dateFormat="yyyy-MM-dd" class="form-control border-right-0 essential-bg calDate" value="${bean.birth_dt}" required="required" alt="생년월일">
														</div>
													</div>
													<div class="col width120px pl5">
														<div class="form-check form-check-inline"  style="margin-right: 0px;">
															<input class="form-check-input" type="radio" name="solar_cal_yn" value="Y" ${bean.solar_cal_yn == 'Y'? 'checked="checked"' : ''}>
															<label class="form-check-label">양력</label>
														</div>
														<div class="form-check form-check-inline"style="margin-right: 0px;">
															<input class="form-check-input" type="radio" name="solar_cal_yn" value="N" ${bean.solar_cal_yn == 'N'? 'checked="checked"' : ''}>
															<label class="form-check-label">음력</label>
														</div>
													</div>
												</div>
											</td> --%>		
											<%-- <th class="text-right">입사일자</th>
											<td>
												<input type="text" id="ipsa_dt" name="ipsa_dt" dateFormat="yyyy-MM-dd" class="form-control width120px" value="${bean.ipsa_dt}" required="required" alt="입사일자" disabled="disabled">
											</td> --%>							
										</tr>
										<tr>
											<th class="text-right essential-item">핸드폰</th>
											<td>
												<div class="form-row inline-pd widthfix">
													<div class="col width110px">
														<input type="text" class="form-control essential-bg" id="hp_no" name="hp_no"  value="${fn:replace(bean.hp_no, '-', '')}" format="phone" placeholder="숫자만 입력"  required="required" alt="핸드폰" minlength="10"  maxlength="11">
													</div>
													<div class="col width60px">
														<button type="button" id="btn_hp_no_chk" class="btn btn-primary-gra" style="width: 100%;" onclick="javascript:goHpNoCheck();" disabled="disabled">중복확인</button>
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">비상연락처</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-6">
														<input type="text" class="form-control essential-bg" id="emergency_contact_relation" name="emergency_contact_relation" placeholder="비상연락처관계"  value="${bean.emergency_contact_relation}"  datatype="string" required="required" alt="비상연락처관계" >
													</div>
													<div class="col-6">
														<input type="text" class="form-control essential-bg" id="emergency_contact_phone_no" name="emergency_contact_phone_no"  placeholder="-없이 숫자만"  value="${bean.emergency_contact_phone_no}" minlength="9"  maxlength="20" required="required" alt="비상연락처" >
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right">전화(사무실)</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-12">
														<input type="text" class="form-control width140px" value="${bean.office_tel_no}" id="office_tel_no" name="office_tel_no" minlength="9" maxlength="20" alt="전화(사무실)">
													</div>
												</div>
											</td>	
										</tr>
										<tr>
											<th class="text-right">전화(팩스)</th>
											<td>
												<div class="form-row inline-pd">
													<div class="col-12">
														<input type="text" class="form-control width140px" value="${bean.office_fax_no}" id="office_fax_no" name="office_fax_no" minlength="9" maxlength="20" alt="전화(팩스)">
													</div>
												</div>
											</td>
										</tr>
										<tr>
											<th class="text-right essential-item">자택주소</th>
											<td>
												<div class="form-row inline-pd mb7 widthfix">
													<div class="col width100px">
														<input type="text" class="form-control essential-bg" value="${bean.home_post_no}" id="home_post_no" name="home_post_no"  readonly="readonly" required="required" alt="자택주소">
													</div>
													<div class="col width60px">
														<button type="button" class="btn btn-primary-gra" id="findAddress" onclick="javascript:openSearchAddrPanel('fnSetAddress');">주소찾기</button>
													</div>
												</div>
												<div class="form-row inline-pd mb7">
													<div class="col-12">
														<input type="text" class="form-control essential-bg" value="${bean.home_addr1}" id="home_addr1" name="home_addr1" readonly="readonly" required="required" alt="자택주소">
													</div>
												</div>
												<div class="form-row inline-pd">
													<div class="col-12">
														<input type="text" class="form-control essential-bg" value="${bean.home_addr2}" id="home_addr2" name="home_addr2">
													</div>
												</div>
											</td>					
										</tr>
										<c:if test="${showLineYn eq 'Y'}">
										<tr>
											<th class="text-right">라인계정연동</th>
											<td colspan="3">
												<c:if test="${not empty bean.access_token}">
													<span>연동일시 : ${bean.line_sync_date} </span>
													<span style="color:red;">인증됨</span>
													<span><button type="button" class="btn btn-primary-gra" onclick="javascript:goRemoveAuthAccount();">인증삭제</button></span>
												</c:if>
												<c:if test="${empty bean.access_token}">
													<span><button type="button" class="btn btn-primary-gra" onclick="javascript:goAuthAccount();">인증하기</button></span>
													&nbsp;&nbsp; 연동아이디 : <label style="color: #ff7f00;">${SecureUser.web_id}@sunnyyk.co.kr</label>
												</c:if>
											</td>									
										</tr>
										</c:if>
									</tbody>
								</table>
							</div>					
							<!-- /폼테이블 -->			
							<!-- 자격사항 -->
							<div class="title-wrap mt10">
								<h4>자격사항</h4>
								<div class="btn-group">
									<div class="right">
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
									</div>
								</div>
							</div>
							<div id="auiGridBom" style="margin-top: 5px; height: 300px;"></div>
							<!-- /자격사항 -->
							<!-- 관리등급기준 설명 -->
							<div class="row mg0">
								<div class="col-12 alert alert-secondary mt10">
									<div class="title">
										<i class="material-iconserror font-16"></i>
										<span>비밀번호변경</span>
									</div>
									<ul>
										<li>로그인화면에서 비밀번호 초기화 후 재설정 하시기 바랍니다.</li>
									</ul>                    
								</div>
							</div>
		<!-- /관리등급기준 설명 -->
							<div class="btn-group">
								<div class="right">
									<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
								</div>				
							</div>
		<!-- /자격사항 -->		
						</div>
					</div>		
				</div>
		<!-- /contents 전체 영역 -->	
		</div>	
	</form>
</body>
</html>