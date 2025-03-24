<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 기준정보 > 마케팅 SMS발송 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-10-08 10:33:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	<%-- 여기에 스크립트 넣어주세요. --%>
	
				   
	
	var hpRegex  = /^(?:(010-?\d{4})|(01[1|6|7|8|9]-?\d{3,4}))-?(\d{4})$/;
		
	$(document).ready(function() {
		fnInitDate();
		createAUIGridArea();
		createAUIGridLeft();
		createAUIGridRight();
	});
	

	// 엔터키 이벤트
	function enter(fieldObj) {
		var field = ["s_center_org_code", "s_maker_cd"];
		$.each(field, function() {
			if(fieldObj.name == this) {
				goSearch();
			};
		});
	}
	
	// 시작일자 세팅 현재날짜의 1달 전
	function fnInitDate() {
		var now = "${inputParam.s_current_dt}";
		$M.setValue("s_start_dt", $M.addMonths($M.toDate(now), -1));
	}
	
	function goSearch() {
		
		if($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {				
			return;
		}; 
	
		var area_sale_code_str = [];
		var areaGridAreaData = AUIGrid.getCheckedRowItems(auiGridArea);
		
		if(areaGridAreaData.length > 0 ) {
			for (var i = 0; i < areaGridAreaData.length; ++i) {
				area_sale_code_str.push(areaGridAreaData[i].item.sale_area_code);
			}
		}
		
		var param = {
			s_start_dt : $M.getValue("s_start_dt"),
			s_end_dt : $M.getValue("s_end_dt"),
			s_center_org_code : $M.getValue("s_center_org_code"), 		// 담당센터
			s_sale_org_code 	: $M.getValue("s_sale_org_code"),		// 영업부문 부서 
			s_sale_sub_org_code : $M.getValue("s_sale_sub_org_code"),	// 영업부문 하위부서
			s_sale_org_mem 		: $M.getValue("s_sale_org_mem"),		// 영업부문 담당자
			s_machine_name : $M.getValue("s_machine_name"), 			// 모델명
			s_maker_cd : $M.getValue("s_maker_cd"), 					// 메이커 
			s_area_sale_code_str : $M.getArrStr(area_sale_code_str),	//영업지역
			"s_masking_yn" : $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
			s_sort_key : "cust_name", 
			s_sort_method : "asc, a.cust_no asc ",
		}
		
		console.log(param);
		
		$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
			function(result){
				if(result.success) {
					$("#list_total_cnt").html(result.list.length);
					AUIGrid.setGridData(auiGridLeft, result.list);
					
					// 발송대상고객 초기화
					AUIGrid.setGridData(auiGridRight, []);	
					$("#target_total_cnt").html(0);					
				}
			}
		);	
	}

	function createAUIGridArea() {
		var gridProsTree = {
		   	 	rowIdField: "_$uid",
               	enableFilter: true,
               	displayTreeOpen: false,
               	showRowCheckColumn: true,
               	rowCheckDependingTree: true,
               	showRowNumColumn: false
		};
        var columnLayoutTree = [
            {
                headerText: "마케팅지역",
                dataField: "sale_area_name",
                style: "aui-left",
                editable: false,
                filter: {
                    showIcon: true
                }
            },
            {
                headerText: "마케팅구역코드",
                dataField: "sale_area_code",
                visible: false
            }
        ];

        auiGridArea = AUIGrid.create("#auiGridArea", columnLayoutTree, gridProsTree);
        AUIGrid.setGridData(auiGridArea, ${saleAreaList});
        $("#auiGridArea").resize();
	}
	
	function createAUIGridLeft() {
		var gridProsLeft = {
		   		rowIdField: "_$uid",
               	enableFilter: true,
				//체크박스 출력 여부
				showRowCheckColumn : true,			
				// 전체 체크박스 표시 설정
				showRowAllCheckBox : true,
				// 전체선택 체크박스가 독립적인 역할을 할지 여부
				independentAllCheckBox : true,
				rowCheckableWithDisabled : true,				
			 	rowCheckableFunction : function(rowIndex, isChecked, item) {
			 		if(item.marketing_yn == 'Y') {			 						 		
						return true;
					}
					else {
						return false;
					}
				},
               	showRowNumColumn: false
		};
		var columnLayout = [
			{
				headerText : "고객명", 
				dataField : "cust_name", 
				width : "12%", 
				style : "aui-center"
			},
			{ 
				headerText : "업체명", 
				dataField : "breg_name", 
				width : "12%",
				style : "aui-center", 
			},
			{ 
				headerText : "모델", 
				dataField : "machine_name", 
				width : "12%", 
				style : "aui-center", 
			},
			{ 
				headerText : "휴대폰", 
				width : "12%",
				dataField : "hp_no", 
				style : "aui-center",
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {					
					if(value != ""){
						return $M.phoneFormat(value,0);
					}
				},
			},
			{ 
				headerText : "전화번호", 
				dataField : "tel_no", 
				width : "12%", 
				style : "aui-center"
			},
			{ 
				headerText : "마케팅동의", 
				dataField : "marketing_yn", 
				width : "10%", 
				style : "aui-center", 
                editable: false,
                filter: {
                    showIcon: true
                }
			},
			{ 
				headerText : "주소", 
				dataField : "addr", 
				style : "aui-left", 
			}
		];

		auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridProsLeft);
		AUIGrid.setGridData(auiGridLeft, []);
		
		$("#auiGridLeft").resize();
		
		// 전체 체크박스 클릭 이벤트 바인딩
		AUIGrid.bind(auiGridLeft, "rowAllChkClick", function( event) {

			if(event.checked) {			
					
				var arrCustNo = [];
				// 화면에 보여지는 그리드 데이터 목록
				var gridLeftAllList = AUIGrid.getGridData(auiGridLeft);
				
				// 마케팅 수신동의 한 고객만 발송대상 추가
				for (var i = 0; i < gridLeftAllList.length; i++) {
					if( gridLeftAllList[i].marketing_yn == 'Y' ) {
						arrCustNo.push(gridLeftAllList[i].cust_no);
					}
				}

				AUIGrid.setCheckedRowsByValue(event.pid, "cust_no", arrCustNo);
			} else {
				AUIGrid.setCheckedRowsByValue(event.pid, "cust_no", []);
			}
		
		});		
	}
	
	function createAUIGridRight() {

		var gridProsRight = {
	   		 	rowIdField: "_$uid",
               	enableFilter: true,
               	displayTreeOpen: false,
               	showRowCheckColumn: true,
               	showRowNumColumn: false
		};
		var columnLayout = [			
			{
				headerText : "고객명", 
				dataField : "receiver_name",
				style : "aui-center"
			}, 	
			{
				headerText : "휴대폰",
				dataField : "phone_no",			
				labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
				     return $M.phoneFormat(value); 
				},
				style : "aui-center"
			},
			{
				dataField : "ref_key",
				headerText : "참조키",
				visible : false
			}
		];

		auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridProsRight);
		AUIGrid.setGridData(auiGridRight, []);
		$("#auiGridRight").resize();
	}
	
	function  goSearchSaleOrg(obj) {			
		//영업부서 초기화및 영업 SUB부서 정보 세팅
		
		if(obj.value != ""){
				
			$M.goNextPageAjax(this_page + "/searchSaleOrg" + "/" +  obj.value,"", {method : "get", loader: false},
				function(result) {
							
		    		if(result.success) {
		    				    		
		    			$("select#s_sale_sub_org_code option").remove();	    				
		    			$('#s_sale_sub_org_code').append('<option value="" >'+ "- 전체 -" +'</option>');	
		    			
		    		 	var saleOrgCode = $M.getValue('s_sale_org_code');
		    		 	
		    			//  선택부서가 농기,OR 건기인 경우 영업 SUB 부서 설정 
		    			if ( result.list != ""  && result.list != undefined && ( saleOrgCode == '4100'  || saleOrgCode == '4500' )) {
	    	    			for(i = 0; i< result.list.length; i++){       		    				
	    		    			var optVal = result.list[i].org_code;
	    		    			var optText = result.list[i].org_kor_name;
	    		    			$('#s_sale_sub_org_code').append('<option value="'+ optVal +'">'+ optText +'</option>');			    			
	    	                }	
		    			}  
		    			
		    			// 선택부서가 영업부인경우  영업부와 센터영업부 직원 가져오기
		    			if ( result.list != ""  && result.list != undefined && ( saleOrgCode == '4000' )) {
		    				goSearchSaleOrgMem(saleOrgCode);
		    			}
		    			else {
		    				//3뎁스  초기화
			    			$("select#s_sale_org_mem option").remove();	    	   			
			    			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
		    			}			
					}

				}
			);		
		}
		else {
 
    			//2뎁스 초기화
    			$("select#s_sale_sub_org_code option").remove();
    			$('#s_sale_sub_org_code').append('<option value="" >'+ "- 전체 -" +'</option>');	
    			//3뎁스 초기화
    			$("select#s_sale_org_mem option").remove();	  
    			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
    		
		}
	}
	
	function  goSearchSaleOrgMem(obj) {	
				
	  	console.log($('#s_sale_org_code').val());
	  		
	  	if(obj.value!=""){

			//영업 SUB부서 초기화및 담당자세팅
			$M.goNextPageAjax(this_page + "/searchSaleOrgMem" + "/" + $('#s_sale_org_code').val()+ "/" + obj.value , "", {method : "get", loader: false},
				function(result) {
					$("select#s_sale_org_mem option").remove();	
					
		 			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
	
	    			if ( result.list != "" && result.list != undefined ) {
	    			
		    			for(i = 0; i< result.list.length; i++){       		    				
			    			var optVal = result.list[i].mem_no;
			    			var optText = result.list[i].kor_name;
			    			$('#s_sale_org_mem').append('<option value="'+ optVal +'">'+ optText +'</option>');			    			
		                }	
	    			
	    			}
				}
			);			
	  	}
	  	else {
			//3뎁스 초기화
			$("select#s_sale_org_mem option").remove();	  
			$('#s_sale_org_mem').append('<option value="" >'+ "- 전체 -" +'</option>');	
	  	}
	}
		
	// 고객 조회
	function fnSetCustInfo(row) {
		if(row.hp_no == "" || row.real_hp_no == ""){
			alert("휴대폰번호가 없습니다.");
			return false;
		}
		
		
		if(AUIGrid.isUniqueValue(auiGridRight, "phone_no", row.real_hp_no)){
			var item = new Object();
			item = {
					phone_no : row.real_hp_no,
					receiver_name : row.real_cust_name,
					ref_key : row.cust_no
			}
								
			AUIGrid.addRow(auiGridRight, item, 'last');
			fnUpdateCnt();
			
			var custInfo = row.real_cust_name + " (" + $M.phoneFormat(row.real_hp_no) + " )";			
			$M.setValue("cust_info",custInfo);			
		}			
	}
	
	// 행 추가, 삽입( 선택한 고객리스트를 발송대상고객에 넣기 )
	function fnAddRowLeft() {	
		var rows = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
		if(rows.length <= 0) {
			alert('추가할 데이터가 없습니다.');
			return;
		};
		
		for (var i = 0; i < rows.length; i++ ) {
					
			if(AUIGrid.isUniqueValue(auiGridRight, "phone_no", rows[i].hp_no ) == true ) {
				
				var item = new Object();
				item.receiver_name =  rows[i].cust_name;
				item.phone_no = rows[i].hp_no;
				item.ref_key = rows[i].cust_no;
				AUIGrid.addRow(auiGridRight, item, 'last');
			}
		
		}
		fnUpdateCnt();
	}
	
	// 행 추가, 삽입
	function fnAddRow() {

		if($M.validation(document.main_form, {field:['add_hp']}) == false) {
			return;
		};
		
		var hp_no = $M.getValue("add_hp");	
		
		if(AUIGrid.isUniqueValue(auiGridRight, "phone_no", hp_no ) == false ) {
			alert("이미 등록된 휴대폰번호입니다.");
			$("#add_hp").focus();
			return;
		}

		if (!hpRegex.test(hp_no)){
			alert("올바른 휴대폰번호를 입력해주세요");
			$("#add_hp").focus();
			return;
		}
		
		var item = new Object();
		item = {
				phone_no : hp_no,
				receiver_name : "임의고객",
				ref_key : ""
		}
							
		AUIGrid.addRow(auiGridRight, item, 'last');
		fnUpdateCnt();		
		
	}
	
	
	function fnUpdateCnt() {
		var cnt = AUIGrid.getGridData(auiGridRight).length;
		$("#target_total_cnt").html(cnt);
	}

	
	// 선택한 로우 삭제 ( 발송대상고객 )
	function fnRemoveRowRight() {
		// 상단 그리드의 체크된 행들 얻기
		var rows = AUIGrid.getCheckedRowItemsAll(auiGridRight);
		if(rows.length <= 0) {
			alert('삭제할 데이터가 없습니다.');
			return;
		};
		AUIGrid.removeCheckedRows(auiGridRight);
		fnUpdateCnt();
	}
	

    // 문자발송
	function fnSendSms() {
    	  	
	 	// 화면에 보여지는 그리드 데이터 목록	
		if(AUIGrid.getGridData(auiGridRight).length < 1 ){
			alert("선택된  고객정보가 없습니다.");
			return;
		}	
    	
		 var param = {
		 			'sms_send_type_cd' : "M",
		   			'req_sendtarger_yn' : "Y"
		 }
		 openSendSmsPanel($M.toGetParam(param));
	}

	function reqSendTargetList(){		
		
		var parentTargetList = [];
		var tempList = AUIGrid.getGridData(auiGridRight);
		for (var i = 0; i < tempList.length; i++) {
			var obj = new Object();
			
			obj['phone_no'] = tempList[i].phone_no;
			obj['receiver_name'] = tempList[i].receiver_name;
			obj['ref_key '] = tempList[i].ref_key ;
			
			parentTargetList.push(obj);
		}
 		return parentTargetList;	
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
					<div class="row">
						<div class="col" style="width: calc(80% - 24px);">
							<div class="row">
								<div class="col-12">
<!-- 검색영역 -->					
									<div class="search-wrap">
										<table class="table">
											<colgroup>
												<col width="60px">
												<col width="100px">
												<col width="50px">
												<col width="110px">
												<col width="100px">
												<col width="100px">
												<col width="100px">
												<col width="100px">
												<col width="*">
											</colgroup>
											<tbody>
												<tr>							
													<th>판매기간</th>	
													<td colspan="3">
														<div class="form-row inline-pd">
															<div class="col-5">
																<div class="input-group">
																	<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="조회 시작일" >
																</div>
															</div>
															<div class="col-auto">~</div>
															<div class="col-5">
																<div class="input-group">
																	<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="조회 완료일" value="${inputParam.s_end_dt}" >
																</div>
															</div>
														</div>
													</td>
													<th>담당센터</th>
													<td >
														<select class="form-control" id="s_center_org_code" name="s_center_org_code" >
															<option value="">- 전체 -</option>
															<c:forEach var="item" items="${orgCenterList}">
																<option value="${item.org_code}">${item.org_name}</option>
															</c:forEach>
														</select>
													</td>									
												</tr>		
												<tr>							
													<th>메이커</th>	
													<td>
														<select class="form-control" id="s_maker_cd" name="s_maker_cd"  >
															<option value="">- 전체 -</option>
															<c:forEach var="item" items="${codeMap['MAKER']}">
																<option value="${item.code_value}">${item.code_name}</option>										
															</c:forEach>	
														</select>
													</td>
													<th>모델</th>
													<td>
														<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
								                     		<jsp:param name="required_field" value="s_machine_name"/>
								                     		<jsp:param name="s_maker_cd" value=""/>
								                     		<jsp:param name="s_machine_type_cd" value=""/>
								                     		<jsp:param name="s_sale_yn" value=""/>
								                     		<jsp:param name="readonly_field" value=""/>
								                     	</jsp:include>
													</td>
		
													<th>마케팅부문</th>
													<td>
														<select class="form-control" id="s_sale_org_code" name="s_sale_org_code"  onchange="javascript:goSearchSaleOrg(this);" >
															<option value="">- 전체 -</option>
															<c:forEach items="${orgList}" var="item">
																<c:if test="${item.org_code eq '4000' }"> 																
																	<option value="${item.org_code}"> ${item.org_name}</option>
																</c:if>
																<c:if test="${item.org_code eq '4100' }"> 
																	<option value="${item.org_code}"> ${item.org_name}</option>
																</c:if>
																<c:if test="${item.org_code eq '4500' }"> 															
																	<option value="${item.org_code}"> ${item.org_name}</option>
																</c:if>
															</c:forEach>
														</select>
													</td>					
													<td>
														<select class="form-control" id="s_sale_sub_org_code" name="s_sale_sub_org_code" onchange="javascript:goSearchSaleOrgMem(this);">
															<option value="">- 전체 -</option>
														</select>
													</td>		
													<td>
														<select class="form-control" id="s_sale_org_mem" name="s_sale_org_mem" >
															<option value="">- 전체 -</option>
														</select>
													</td>				
													<td class="">
														<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
													</td>
												</tr>					
											</tbody>
										</table>
									</div>
<!-- /검색영역 -->	
								</div>
							</div>
							<div class="row">
								<div class="col" style="width: 20%">
<!-- 지역선택 -->
									<div class="title-wrap mt10">
										<h4>지역선택</h4>
									</div>
									<div id="auiGridArea" style="margin-top: 5px; height: 550px;"></div>
<!-- /지역선택 -->
								</div>
<!-- 우측 화살표 -->
								<div class="col btn-switch">								
									<i class="material-iconschevron_right text-default font-30"></i>
								</div>
<!-- /우측 화살표 -->
								<div class="col" style="width: calc(80% - 24px);">
<!-- 조회결과 -->
									<div class="title-wrap mt10">
										<h4>조회결과</h4>
										<div class="btn-group">
											<div class="right">
												<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
												<div class="form-check form-check-inline">
													<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
													<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
												</div>
												</c:if>													
												<button type="button" class="btn btn-default" onclick="javascript:fnAddRowLeft();" ><i class="material-iconsdone text-default"></i>체크 후 추가</button>	
											</div>
										</div>
									</div>
									<div id="auiGridLeft" style="margin-top: 5px; height: 550px;"></div>
									<div class="btn-group mt5">	
										<div class="left">
											총 <strong class="text-primary" id="list_total_cnt" >0</strong>명
										</div>
									</div>
<!-- /조회결과 -->
								</div>
							</div>
						</div>
<!-- 우측 화살표 -->
						<div class="col btn-switch" style="padding-top: 32px;">								
							<i class="material-iconschevron_right text-default font-30"></i>
						</div>
<!-- /우측 화살표 -->						
						<div class="col" style="width: 20%;">
							<div class="row">
								<div class="col-12">
<!-- 검색영역 -->					
									<div class="search-wrap">
										<table class="table">
											<colgroup>
												<col width="55px">
												<col width="*">
											</colgroup>
											<tbody>
												<tr>							
													<th>고객조회</th>	
													<td>
														<div class="input-group">														
															<input type="text" class="form-control border-right-0" id="cust_info" name="cust_info" readonly="readonly" placeholder="">
															<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:openSearchCustPanel('fnSetCustInfo');"><i class="material-iconssearch"></i></button>							
														</div>		
													</td>	
												</tr>
												<tr>							
													<th>수신번호</th>	
													<td>
														<div class="form-row inline-pd">
															<div class="col-7">
																<input type="text" class="form-control"  id="add_hp" name="add_hp" alt="수신번호" placeholder="-없이 숫자만" datatype="int" >
															</div>
															<div class="col-5">
																<button type="button" class="btn btn-primary-gra" style="width: 100%;"  onclick="javascript:fnAddRow()" >개별추가</button>
															</div>
														</div>
													</td>	
												</tr>											
											</tbody>
										</table>
									</div>
<!-- /검색영역 -->	
								</div>
							</div>
							<div class="row">
								<div class="col-12">
<!-- 발송대상고객 -->
									<div class="title-wrap mt10">
										<h4>발송대상고객</h4>
										<div class="btn-group">
											<div class="right">
												<button type="button" class="btn btn-default" onclick="javascript:fnRemoveRowRight();"><i class="material-iconsdone text-default"></i>체크 후 삭제</button>	
											</div>
										</div>
									</div>
									<div id="auiGridRight" style="margin-top: 5px; height: 550px;"></div>
									<div class="btn-group mt5">	
										<div class="left">
											발송대상 <strong class="text-primary" id="target_total_cnt" >0</strong>명
										</div>
									</div>
<!-- /발송대상고객 -->
									<div class="btn-group">
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>						
			</div>	
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>	
		</div>
<!-- /contents 전체 영역 -->	
	</div>	
</form>
</body>
</html>